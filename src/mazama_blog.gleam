import blogatto
import blogatto/error
import gleam/io
import mazama_blog/site

pub fn main() {
  case blogatto.build(site.config()) {
    Ok(Nil) -> io.println("Site généré avec succès !")
    Error(err) ->
      io.println("Échec de la génération : " <> error.describe_error(err))
  }
}
