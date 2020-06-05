alias Vereine.{
  Aggregates.Application,
  Commands
}

{:ok, id} = %{name: "test"} |> Vereine.submit_application()

Vereine.allow_employment(id)
Vereine.allow_funding(id)
Vereine.finalize_application(id)

Organizations.all()
