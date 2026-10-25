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
    Ok(Nil) -> io.println("Serveur de développement arrêté.")
    Error(err) ->
      io.println(
        "Erreur du serveur de développement : " <> error.describe_error(err),
      )
  }
}
