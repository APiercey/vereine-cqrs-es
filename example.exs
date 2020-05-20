alias Vereine.{
  Aggregates.Organization,
  Commands
}

id = Organization.generate_id()

[
  %Commands.SubmitApplication{id: id, name: "test"},
  %Commands.AddFeature{id: id, feature: :fundable},
  %Commands.AddFeature{id: id, feature: :employeer},
  %Commands.FinalizeApplication{id: id}
]
|> Enum.map(&Organization.dispatch/1)

Web.Organizations.one(id)
Web.Organizations.all()
