import blogatto
import blogatto/error
import gleam/io
import mazama_blog/site

pub fn main() {
  case blogatto.build(site.config()) {
    Ok(Nil) -> io.println("Site built successfully!")
    Error(err) -> io.println("Build failed: " <> error.describe_error(err))
  }
}
