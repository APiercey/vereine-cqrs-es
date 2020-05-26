defprotocol CQRSComponents.Command do
  def valid?(command)
end
