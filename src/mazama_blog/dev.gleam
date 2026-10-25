import blogatto/dev
import blogatto/error
import gleam/io
import mazama_blog/site

pub fn main() {
  case
    site.config()
    |> dev.new()
    |> dev.build_command("gleam run -m mazama_blog")
    |> dev.port(3000)
    |> dev.start()
  {
    Ok(Nil) -> io.println("Dev server stopped.")
    Error(err) -> io.println("Dev server error: " <> error.describe_error(err))
  }
}
