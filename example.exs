alias Vereine.{
  Aggregates.Application,
  Commands
}

id = Application.generate_id()

[
  %Commands.SubmitApplication{id: id, name: "test"},
  %Commands.AddFeature{id: id, feature: :fundable},
  %Commands.AddFeature{id: id, feature: :employeer},
  %Commands.FinalizeApplication{id: id}
]
|> Enum.map(&Application.dispatch/1)

Organizations.one(id)
Organizations.all()
