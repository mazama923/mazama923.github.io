import blogatto
import blogatto/config.{Config}
import blogatto/config/post as post_config
import blogatto/post.{type Post, Post, PostMetadata}
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleam/time/timestamp
import gleeunit/should
import lustre/attribute
import lustre/element
import lustre/element/html
import mazama_blog/site

@external(erlang, "seo_fixture_files", "create_directory")
fn create_directory(path: String) -> Result(Nil, String)

@external(erlang, "seo_fixture_files", "create_directory_all")
fn create_directory_all(path: String) -> Result(Nil, String)

@external(erlang, "seo_fixture_files", "write")
fn write_file(path: String, contents: String) -> Result(Nil, String)

@external(erlang, "seo_fixture_files", "read")
fn read_file(path: String) -> Result(String, String)

@external(erlang, "seo_fixture_files", "delete")
fn delete_directory(path: String) -> Result(Nil, String)

fn post_config() {
  site.config().post_config |> should.be_some
}

fn render_route(route: String) -> String {
  let view = dict.get(site.config().routes, route) |> should.be_ok
  view([]) |> element.to_document_string
}

fn render_post(post: Post(Nil)) -> String {
  let template = post_config().template |> should.be_some
  template(post, []) |> element.to_document_string
}

fn sample_post(
  kind: String,
  slug: String,
  contents: List(element.Element(Nil)),
) -> Post(Nil) {
  let config = post_config()
  let metadata =
    PostMetadata(
      title: "Frontmatter title",
      slug: slug,
      date: timestamp.from_unix_seconds(0),
      description: "A sample description",
      language: None,
      featured_image: None,
      extras: dict.from_list([#("type", kind)]),
    )
  let route_builder = config.route_builder |> should.be_some
  Post(
    title: metadata.title,
    slug: metadata.slug,
    url: site.config().site_url <> route_builder(metadata),
    date: metadata.date,
    description: metadata.description,
    excerpt: "",
    language: metadata.language,
    featured_image: metadata.featured_image,
    contents: contents,
    extras: metadata.extras,
  )
}

fn occurrences(value: String, pattern: String) -> Int {
  list.length(string.split(value, pattern)) - 1
}

fn assert_canonical(document: String, url: String) -> Nil {
  let links =
    document
    |> string.split("<link ")
    |> list.filter(fn(part) {
      let tag = string.split(part, ">") |> list.first |> should.be_ok
      string.contains(tag, "rel=\"canonical\"")
    })
  list.length(links) |> should.equal(1)
  let tag = links |> list.first |> should.be_ok
  let tag = string.split(tag, ">") |> list.first |> should.be_ok
  string.contains(tag, "href=\"" <> url <> "\"") |> should.be_true
}

fn fixture(kind: String, slug: String, body: String) -> String {
  "---\ntitle: Fixture title\ndate: 2025-01-01 00:00:00\ndescription: Fixture description\ntype: "
  <> kind
  <> "\nslug: "
  <> slug
  <> "\n---\n\n"
  <> body
}

fn build_fixture_site(root: String) -> Result(List(String), String) {
  let input = root <> "/input"
  let output = root <> "/output"
  use _ <- result.try(
    create_directory_all(input <> "/post")
    |> result.replace_error("Could not create post fixture directory"),
  )
  use _ <- result.try(
    create_directory_all(input <> "/page")
    |> result.replace_error("Could not create page fixture directory"),
  )
  let matching_heading = "# Fixture title\n\nFixture body.\n"
  let different_headings =
    "# A **meaningful** title\n\nBody text.\n\n# Later section\n\nDetails.\n"
  use _ <- result.try(
    write_file(
      input <> "/post/index.md",
      fixture("post", "sample-post", matching_heading),
    )
    |> result.replace_error("Could not write post fixture"),
  )
  use _ <- result.try(
    write_file(
      input <> "/page/index.md",
      fixture("page", "sample-page", matching_heading),
    )
    |> result.replace_error("Could not write page fixture"),
  )
  use _ <- result.try(
    create_directory_all(input <> "/post-variants")
    |> result.replace_error("Could not create post variants directory"),
  )
  use _ <- result.try(
    create_directory_all(input <> "/page-variants")
    |> result.replace_error("Could not create page variants directory"),
  )
  use _ <- result.try(
    write_file(
      input <> "/post-variants/index.md",
      fixture("post", "post-variants", different_headings),
    )
    |> result.replace_error("Could not write post variants fixture"),
  )
  use _ <- result.try(
    write_file(
      input <> "/page-variants/index.md",
      fixture("page", "page-variants", different_headings),
    )
    |> result.replace_error("Could not write page variants fixture"),
  )
  let config = site.config()
  let post = post_config.PostConfig(..post_config(), paths: [input])
  let config =
    Config(
      ..config,
      output_dir: output,
      static_dir: None,
      post_config: Some(post),
    )
  use _ <- result.try(
    blogatto.build(config)
    |> result.map_error(fn(error) { string.inspect(error) }),
  )
  [
    "/sitemap.xml",
    "/index.html",
    "/blog/index.html",
    "/blog/sample-post/index.html",
    "/sample-page/index.html",
    "/blog/post-variants/index.html",
    "/page-variants/index.html",
  ]
  |> list.try_map(fn(path) {
    read_file(output <> path)
    |> result.replace_error("Could not read " <> path)
  })
}

pub fn generated_sitemap_matches_all_page_canonicals_test() {
  let #(seconds, nanos) =
    timestamp.system_time() |> timestamp.to_unix_seconds_and_nanoseconds
  let root =
    "test/.seo-fixture-"
    <> int.to_string(seconds)
    <> "-"
    <> int.to_string(nanos)
  create_directory(root) |> should.be_ok
  let built = build_fixture_site(root)
  delete_directory(root) |> should.be_ok
  let documents = built |> should.be_ok
  let assert [sitemap, home, blog, post, page, post_variants, page_variants] =
    documents
  [post, page]
  |> list.each(fn(document) {
    occurrences(document, "<h1") |> should.equal(1)
    string.contains(document, "<h1>Fixture title</h1>") |> should.be_true
    string.contains(document, "<p>Fixture body.</p>") |> should.be_true
  })
  [post_variants, page_variants]
  |> list.each(fn(document) {
    occurrences(document, "<h1") |> should.equal(3)
    string.contains(
      document,
      "<h1>A <strong>meaningful</strong> title</h1><p>Body text.</p><h1>Later section</h1><p>Details.</p>",
    )
    |> should.be_true
  })
  let base = site.config().site_url
  [
    #(home, base <> "/"),
    #(blog, base <> "/blog"),
    #(post, base <> "/blog/sample-post/"),
    #(page, base <> "/sample-page/"),
    #(post_variants, base <> "/blog/post-variants/"),
    #(page_variants, base <> "/page-variants/"),
  ]
  |> list.each(fn(entry) {
    assert_canonical(entry.0, entry.1)
    string.contains(sitemap, "<loc>" <> entry.1 <> "</loc>") |> should.be_true
  })
}

pub fn static_routes_have_sitemap_canonicals_test() {
  let config = site.config()
  let home = render_route("/")
  let blog = render_route("/blog")
  assert_canonical(home, config.site_url <> "/")
  assert_canonical(blog, config.site_url <> "/blog")
  string.contains(
    home,
    "<title>DevOps : observabilité, automatisation et exploitation · Mazama</title>",
  )
  |> should.be_true
  let description =
    html.meta([
      attribute.name("description"),
      attribute.content(
        "Notes de terrain sur l'observabilité, l'automatisation et les pratiques d'exploitation DevOps.",
      ),
    ])
    |> element.to_string
  string.contains(home, description) |> should.be_true
}

pub fn content_canonicals_follow_configured_routes_test() {
  let contents = [html.p([], [html.text("A paragraph.")])]
  let post = sample_post("post", "sample-post", contents)
  let page = sample_post("page", "sample-page", contents)
  post.url |> should.equal(site.config().site_url <> "/blog/sample-post/")
  page.url |> should.equal(site.config().site_url <> "/sample-page/")
  assert_canonical(render_post(post), post.url)
  assert_canonical(render_post(page), page.url)
}

pub fn identical_leading_heading_is_removed_for_posts_and_pages_test() {
  let contents = [
    html.h1([], [html.text("Frontmatter title")]),
    html.p([], [html.text("Body text.")]),
  ]
  ["post", "page"]
  |> list.each(fn(kind) {
    let document = sample_post(kind, "sample", contents) |> render_post
    occurrences(document, "<h1") |> should.equal(1)
    string.contains(document, "<h1>Frontmatter title</h1>") |> should.be_true
    string.contains(document, "<div class=\"prose\"><p>Body text.</p>")
    |> should.be_true
  })
}

pub fn differing_leading_heading_and_frontmatter_are_preserved_test() {
  let contents = [
    element.none(),
    html.h1([], [
      html.text("A "),
      html.strong([], [html.text("meaningful")]),
      html.text(" title"),
    ]),
    html.p([], [html.text("Body text.")]),
  ]
  ["post", "page"]
  |> list.each(fn(kind) {
    let document = sample_post(kind, "sample", contents) |> render_post
    occurrences(document, "<h1") |> should.equal(2)
    string.contains(document, "<h1>Frontmatter title</h1>") |> should.be_true
    string.contains(document, "<title>Frontmatter title · Mazama</title>")
    |> should.be_true
    string.contains(
      document,
      "<div class=\"prose\"><h1>A <strong>meaningful</strong> title</h1><p>Body text.</p>",
    )
    |> should.be_true
  })
}

pub fn leading_heading_with_equivalent_text_and_markup_is_preserved_test() {
  let contents = [
    element.none(),
    html.h1([], [
      html.text("Frontmatter "),
      html.strong([], [html.text("title")]),
    ]),
    html.p([], [html.text("Body text.")]),
  ]
  ["post", "page"]
  |> list.each(fn(kind) {
    let document = sample_post(kind, "sample", contents) |> render_post
    occurrences(document, "<h1") |> should.equal(2)
    string.contains(document, "<h1>Frontmatter title</h1>") |> should.be_true
    string.contains(
      document,
      "<div class=\"prose\"><h1>Frontmatter <strong>title</strong></h1><p>Body text.</p>",
    )
    |> should.be_true
  })
}

pub fn duplicate_heading_later_in_the_content_is_preserved_test() {
  let contents = [
    html.h1([], [html.text("Frontmatter title")]),
    html.p([], [html.text("Introduction.")]),
    html.h1([], [html.text("Frontmatter title")]),
  ]
  ["post", "page"]
  |> list.each(fn(kind) {
    let document = sample_post(kind, "sample", contents) |> render_post
    occurrences(document, "<h1") |> should.equal(2)
    string.contains(
      document,
      "<div class=\"prose\"><p>Introduction.</p><h1>Frontmatter title</h1>",
    )
    |> should.be_true
  })
}

pub fn escaped_plain_heading_is_deduplicated_test() {
  let post = sample_post("post", "sample", [])
  let post =
    Post(..post, title: "R&D <site>", contents: [
      html.h1([], [html.text("R&D <site>")]),
    ])
  let document = render_post(post)
  occurrences(document, "<h1") |> should.equal(1)
  string.contains(document, "<h1>R&amp;D &lt;site&gt;</h1>") |> should.be_true
}

pub fn later_heading_is_preserved_after_an_initial_heading_test() {
  let contents = [
    html.h1([], [html.text("Opening title")]),
    html.p([], [html.text("Introduction.")]),
    html.h1([], [html.text("Later section")]),
    html.p([], [html.text("Details.")]),
  ]
  ["post", "page"]
  |> list.each(fn(kind) {
    let document = sample_post(kind, "sample", contents) |> render_post
    occurrences(document, "<h1") |> should.equal(3)
    string.contains(document, "<h1>Frontmatter title</h1>") |> should.be_true
    string.contains(
      document,
      "<div class=\"prose\"><h1>Opening title</h1><p>Introduction.</p><h1>Later section</h1><p>Details.</p>",
    )
    |> should.be_true
  })
}

pub fn leading_heading_preserves_its_attributes_test() {
  ["post", "page"]
  |> list.each(fn(kind) {
    let post = sample_post(kind, "sample", [])
    let post =
      Post(..post, contents: [
        element.none(),
        html.h1([attribute.id("original-heading")], [
          html.text("Frontmatter title"),
        ]),
        html.p([], [html.text("Body text.")]),
      ])
    let document = render_post(post)
    occurrences(document, "<h1") |> should.equal(2)
    string.contains(document, "<h1>Frontmatter title</h1>") |> should.be_true
    string.contains(document, "id=\"original-heading\"") |> should.be_true
    string.contains(document, "<div class=\"prose\"><h1") |> should.be_true
  })
}

pub fn visible_content_before_matching_heading_is_preserved_test() {
  ["post", "page"]
  |> list.each(fn(kind) {
    let post = sample_post(kind, "sample", [])
    let post =
      Post(..post, contents: [
        element.none(),
        html.p([], [html.text("Introduction.")]),
        html.h1([], [html.text("Frontmatter title")]),
      ])
    let document = render_post(post)
    occurrences(document, "<h1") |> should.equal(2)
    string.contains(
      document,
      "<div class=\"prose\"><p>Introduction.</p><h1>Frontmatter title</h1>",
    )
    |> should.be_true
  })
}

pub fn whitespace_text_before_matching_heading_is_preserved_test() {
  let post = sample_post("post", "sample", [])
  let post =
    Post(..post, contents: [
      element.none(),
      html.text(" "),
      html.h1([], [html.text("Frontmatter title")]),
    ])
  let document = render_post(post)
  occurrences(document, "<h1") |> should.equal(2)
  string.contains(document, "<div class=\"prose\"> <h1>Frontmatter title</h1>")
  |> should.be_true
}

pub fn later_headings_are_not_removed_or_reordered_test() {
  let contents = [
    html.p([], [html.text("An introduction.")]),
    html.h1([], [html.text("A later heading")]),
    html.p([], [html.text("Some details.")]),
    html.h1([], [html.text("Another heading")]),
  ]
  ["post", "page"]
  |> list.each(fn(kind) {
    let document = sample_post(kind, "sample", contents) |> render_post
    occurrences(document, "<h1") |> should.equal(3)
    string.contains(document, "<h1>Frontmatter title</h1>") |> should.be_true
    string.contains(
      document,
      "<p>An introduction.</p><h1>A later heading</h1><p>Some details.</p><h1>Another heading</h1>",
    )
    |> should.be_true
  })
}

pub fn empty_content_gets_a_generated_heading_test() {
  let document = sample_post("post", "sample", []) |> render_post
  occurrences(document, "<h1") |> should.equal(1)
  string.contains(document, "<h1>Frontmatter title</h1>") |> should.be_true
}
