alias Vereine.{
  Aggregates.Organization,
  Commands
}

id = Organization.generate_id()

%Commands.SubmitApplication{id: id, name: "test"} |> Organization.dispatch()
%Commands.AddFeature{id: id, feature: :fundable} |> Organization.dispatch()
%Commands.AddFeature{id: id, feature: :employeer} |> Organization.dispatch()
%Commands.FinalizeApplication{id: id} |> Organization.dispatch()

Web.Organizations.one(id)
Web.Organizations.all()
