import blogatto/config
import blogatto/config/feed/rss
import blogatto/config/post as post_config
import blogatto/config/robots
import blogatto/config/sitemap
import blogatto/post.{type Post, type PostMetadata}
import gleam/dict
import gleam/list
import gleam/time/timestamp
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

const site_url = "https://mazama923.github.io"

pub fn config() -> config.Config(Nil) {
  let post_config =
    post_config.default()
    |> post_config.path("./blog")
    |> post_config.route_builder(route_for)
    |> post_config.template(post_template)

  let rss_feed =
    rss.new(
      "Mazama — Carnet d'atelier DevOps",
      site_url,
      "Notes de terrain sur l'exploitation, l'automatisation et la fiabilité.",
    )
    |> rss.language("fr-fr")
    |> rss.generator("Blogatto")
    |> rss.output("/rss.xml")
    |> rss.filter(fn(metadata) { is_post(metadata.post) })

  let robots_config =
    robots.RobotsConfig(sitemap_url: site_url <> "/sitemap.xml", robots: [
      robots.Robot(
        user_agent: "*",
        allowed_routes: ["/"],
        disallowed_routes: [],
      ),
    ])

  config.new(site_url)
  |> config.output_dir("./dist")
  |> config.static_dir("./static")
  |> config.post(post_config)
  |> config.route("/", home_view)
  |> config.route("/blog", blog_view)
  |> config.rss_feed(rss_feed)
  |> config.sitemap(sitemap.new("/sitemap.xml"))
  |> config.robots(robots_config)
}

fn route_for(metadata: PostMetadata) -> String {
  case dict.get(metadata.extras, "type") {
    Ok("page") -> "/" <> metadata.slug <> "/"
    _ -> "/blog/" <> metadata.slug <> "/"
  }
}

fn is_post(post: Post(msg)) -> Bool {
  case dict.get(post.extras, "type") {
    Ok("post") -> True
    _ -> False
  }
}

fn sorted_posts(posts: List(Post(msg))) -> List(Post(msg)) {
  posts
  |> list.filter(is_post)
  |> list.sort(fn(a, b) { timestamp.compare(b.date, a.date) })
}

fn home_view(posts: List(Post(msg))) -> Element(msg) {
  page("Accueil", "Notes de terrain DevOps de Mazama.", [
    html.section([attribute.class("hero")], [
      html.p([attribute.class("eyebrow")], [
        html.text("Carnet d'atelier DevOps"),
      ]),
      html.h1([], [
        html.text(
          "Des systèmes qui tournent rond, des notes qui vont droit au but.",
        ),
      ]),
      html.p([], [
        html.text(
          "Observabilité, automatisation et pratiques d'exploitation qui tiennent dans la durée.",
        ),
      ]),
      html.a([attribute.class("button"), attribute.href("/blog")], [
        html.text("Lire les notes"),
      ]),
    ]),
    post_list("Dernières notes", sorted_posts(posts) |> list.take(6)),
  ])
}

fn blog_view(posts: List(Post(msg))) -> Element(msg) {
  page("Blog", "Toutes les notes d'exploitation publiées par Mazama.", [
    html.section([attribute.class("page-intro")], [
      html.p([attribute.class("eyebrow")], [html.text("Journal de bord")]),
      html.h1([], [html.text("Notes d'exploitation")]),
      html.p([], [
        html.text(
          "Des repères concrets pour opérer, diagnostiquer et automatiser sans bruit inutile.",
        ),
      ]),
    ]),
    post_list("Toutes les notes", sorted_posts(posts)),
  ])
}

fn post_template(post: Post(msg), _all_posts: List(Post(msg))) -> Element(msg) {
  case dict.get(post.extras, "type") {
    Ok("page") -> page_template(post)
    _ ->
      page(post.title, post.description, [
        html.article([attribute.class("post")], [
          html.header([attribute.class("post-header")], [
            html.p([attribute.class("eyebrow")], [html.text("Note de terrain")]),
            html.h1([], [html.text(post.title)]),
            html.p([attribute.class("lede")], [html.text(post.description)]),
          ]),
          html.div([attribute.class("prose")], post.contents),
        ]),
      ])
  }
}

fn page_template(post: Post(msg)) -> Element(msg) {
  let article =
    html.article([attribute.class("post page")], [
      html.header([attribute.class("post-header")], [
        html.h1([], [html.text(post.title)]),
        html.p([attribute.class("lede")], [html.text(post.description)]),
      ]),
      html.div([attribute.class("prose")], post.contents),
    ])

  page(post.title, post.description, [article])
}

fn post_list(title: String, posts: List(Post(msg))) -> Element(msg) {
  html.section([attribute.class("post-list")], [
    html.h2([], [html.text(title)]),
    html.div([attribute.class("post-grid")], list.map(posts, post_card)),
  ])
}

fn post_card(post: Post(msg)) -> Element(msg) {
  html.article([attribute.class("post-card")], [
    html.h3([], [
      html.a([attribute.href(post.url)], [html.text(post.title)]),
    ]),
    html.p([], [html.text(post.description)]),
    html.a([attribute.class("text-link"), attribute.href(post.url)], [
      html.text("Lire la note →"),
    ]),
  ])
}

fn page(
  title: String,
  description: String,
  content: List(Element(msg)),
) -> Element(msg) {
  html.html([attribute.lang("fr")], [
    html.head([], [
      html.meta([attribute.charset("utf-8")]),
      html.meta([
        attribute.name("viewport"),
        attribute.content("width=device-width, initial-scale=1"),
      ]),
      html.meta([
        attribute.name("description"),
        attribute.content(description),
      ]),
      html.link([
        attribute.rel("icon"),
        attribute.href("/assets/favicon.ico"),
      ]),
      html.title([], title <> " · Mazama"),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/styles/site.css"),
      ]),
      html.link([
        attribute.rel("alternate"),
        attribute.type_("application/rss+xml"),
        attribute.title("Flux RSS Mazama"),
        attribute.href("/rss.xml"),
      ]),
      html.script(
        [
          attribute.attribute("async", ""),
          attribute.attribute("defer", ""),
          attribute.attribute(
            "data-website-id",
            "8d391fde-2554-4743-a4a5-534d78febcbd",
          ),
          attribute.attribute("data-domains", "mazama923.github.io"),
          attribute.src("https://umami.mazama923.duckdns.org/script.js"),
        ],
        "",
      ),
    ]),
    html.body([], [
      html.header([attribute.class("site-header")], [
        html.div([attribute.class("shell header-inner")], [
          html.a([attribute.class("site-name"), attribute.href("/")], [
            html.text("Mazama"),
          ]),
          html.nav([attribute.aria_label("Navigation principale")], [
            html.a([attribute.href("/blog")], [html.text("Les notes")]),
            html.a([attribute.href("/about/")], [html.text("À propos")]),
          ]),
        ]),
      ]),
      html.main([attribute.class("shell")], content),
      html.footer([attribute.class("site-footer")], [
        html.div([attribute.class("shell")], [
          html.p([], [html.text("Mazama · Carnet d'atelier DevOps")]),
          html.a([attribute.href("/rss.xml")], [html.text("Flux RSS")]),
        ]),
      ]),
    ]),
  ])
}
