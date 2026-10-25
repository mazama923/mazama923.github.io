import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn harness_runs_test() {
  1 |> should.equal(1)
}
