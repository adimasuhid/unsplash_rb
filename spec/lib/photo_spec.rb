require "spec_helper"

describe Unsplash::Photo do

  describe "#find" do
    let(:photo_id) { "tAKXap853rY" }
    let(:fake_id)  { "abc123" }

    it "returns a Photo object" do
      VCR.use_cassette("photos") do
        @photo = Unsplash::Photo.find(photo_id)
      end

      expect(@photo).to be_a Unsplash::Photo
    end

    it "errors if the photo doesn't exist" do
      expect {
        VCR.use_cassette("photos") do
          @photo = Unsplash::Photo.find(fake_id)
        end
      }.to raise_error Unsplash::Error
    end

    it "parses the nested user object" do
      VCR.use_cassette("photos") do
        @photo = Unsplash::Photo.find(photo_id)
      end

      expect(@photo.user).to be_an Unsplash::User
    end
  end

  describe "#random" do
  
    let(:params) do
      {
        categories: [2],
        featured:   true,
        width:      320,
        height:     200
      }
    end

    it "returns a Photo object" do
      VCR.use_cassette("photos") do
        @photo = Unsplash::Photo.random(params)
      end

      expect(@photo).to be_a Unsplash::Photo
    end

    it "errors if there are no photos to choose from" do
      expect {
        VCR.use_cassette("photos") do
          @photo = Unsplash::Photo.random(user: "bigfoot")
        end
      }.to raise_error Unsplash::Error
    end

    it "parses the nested user object" do
      VCR.use_cassette("photos") do
        @photo = Unsplash::Photo.random(params)
      end

      expect(@photo.user).to be_an Unsplash::User
    end

    context "with categories" do
      it "joins them" do
        expect(Unsplash::Photo.connection)
          .to receive(:get).with("/photos/random", category: "1,2,3")
          .and_return double(body: "{}")

        photo = Unsplash::Photo.random(categories: [1,2,3])
      end
    end

    context "without categories" do
      it "removes them" do
        expect(Unsplash::Photo.connection)
          .to receive(:get).with("/photos/random", {})
          .and_return double(body: "{}")

        photo = Unsplash::Photo.random
      end
    end

  end

  describe "#search" do
    it "returns an array of Photos" do
      VCR.use_cassette("photos") do
        @photos = Unsplash::Photo.search("dog", 1, 4)
      end

      expect(@photos).to be_an Array
      expect(@photos.size).to eq 4
    end
  end

  describe "#index" do
    it "returns an array of Photos" do
      VCR.use_cassette("photos") do
        @photos = Unsplash::Photo.all(1, 6)
      end

      expect(@photos).to be_an Array
      expect(@photos.size).to eq 6
    end
  end

  describe "#create" do
    let (:filepath) {  }

    it "returns a Photo object" do
      stub_oauth_authorization

      VCR.use_cassette("photos", match_requests_on: [:method, :path, :body]) do
        @photo = Unsplash::Photo.create "spec/support/upload-1.txt"
      end
      
      expect(@photo).to be_an Unsplash::Photo
    end

    it "fails without a Bearer token" do
      expect {
        VCR.use_cassette("photos", match_requests_on: [:method, :path, :body]) do
          @photo = Unsplash::Photo.create "spec/support/upload-2.txt"
        end
      }.to raise_error Unsplash::Error
    end

    it "parses the nested user object" do
      stub_oauth_authorization

      VCR.use_cassette("photos", match_requests_on: [:method, :path, :body]) do
        @photo = Unsplash::Photo.create "spec/support/upload-1.txt"
      end

      expect(@photo.user).to be_an Unsplash::User
    end
  end


end