require "rails_helper"

RSpec.describe "PWA installability" do
  it "serves a valid web app manifest with icons" do
    get "/manifest.json"

    expect(response).to have_http_status(:ok)
    manifest = JSON.parse(response.body)
    expect(manifest["name"]).to eq("Alphabet Trace")
    expect(manifest["display"]).to eq("standalone")
    expect(manifest["icons"].map { |i| i["sizes"] }).to include("192x192", "512x512")
  end

  it "serves the service worker" do
    get "/service-worker.js"

    expect(response).to have_http_status(:ok)
  end
end
