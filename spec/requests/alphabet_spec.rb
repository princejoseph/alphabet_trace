require "rails_helper"

RSpec.describe "Alphabet routing" do
  it "renders the AlphabetTraceApp component for a valid letter" do
    get "/a"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("AlphabetTraceApp")
    expect(response.body).to include(CGI.escapeHTML('"letter":"a"'))
  end

  it "renders the last letter of the alphabet" do
    get "/z"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(CGI.escapeHTML('"letter":"z"'))
  end

  it "redirects the root path to the first letter" do
    get "/"

    expect(response).to redirect_to("/a")
  end

  it "404s for a multi-character segment" do
    get "/ab"

    expect(response).to have_http_status(:not_found)
  end

  it "404s for an uppercase letter" do
    get "/A"

    expect(response).to have_http_status(:not_found)
  end

  it "404s for a non-letter segment" do
    get "/1"

    expect(response).to have_http_status(:not_found)
  end
end
