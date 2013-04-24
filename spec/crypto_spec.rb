require_relative 'helper'
require_relative '../lib/lotus/crypto.rb'

describe Lotus::Crypto do
  before do
    key = Struct.new(:modulus, :exponent).new(256, 2)
    key.stubs(:is_a?).returns(true)

    keypair = Struct.new(:public_key, :private_key).new(key, key)
    keypair.stubs(:decrypt).returns("DECRYPTED")
    keypair.stubs(:encrypt).returns("ENCRYPTED")

    RSA::KeyPair.stubs(:generate).returns(keypair)
    RSA::KeyPair.stubs(:new).returns(keypair)

    Base64::stubs(:urlsafe_encode64).returns("Base64")
    Base64::stubs(:urlsafe_decode64).returns("2")

    RSA::Key.stubs(:new).returns(key)

    Digest::SHA2.any_instance.stubs(:digest).returns("SHA2")
  end

  describe "new_keypair" do
    it "should return a KeyPair structure" do
      Lotus::Crypto.new_keypair.class.must_equal Lotus::Crypto::KeyPair
    end

    it "should return a KeyPair structure with an RSA public key" do
      Lotus::Crypto.new_keypair.public_key.must_match /^RSA\.(.*?)\.(.*)$/
    end

    it "should return a KeyPair structure with an RSA private key" do
      Lotus::Crypto.new_keypair.private_key.must_match /^RSA\.(.*?)\.(.*)$/
    end

    it "should relegate to RSA::KeyPair" do
      keypair = RSA::KeyPair.generate
      RSA::KeyPair.expects(:generate).returns(keypair)
      Lotus::Crypto.new_keypair
    end
  end

  describe "emsa_sign" do
    it "should return a string with the EMSA prefix" do
      keypair = Lotus::Crypto.new_keypair

      sequence = "^\x00\x01\x00\x30\x31\x30\x0d\x06\x09\x60\x86\x48\x01\x65\x03\x04\x02\x01\x05\x00\x04\x20"
      matcher = Regexp.new(sequence, nil, 'n')

      RSA::KeyPair.new.expects(:decrypt).with(regexp_matches(matcher))
      Lotus::Crypto.emsa_sign "payload", keypair.private_key
    end

    it "should return the result of decryption with the private key" do
      keypair = Lotus::Crypto.new_keypair
      Lotus::Crypto.emsa_sign("payload", keypair.private_key)
                   .must_equal "DECRYPTED"
    end

    it "should end the signature with the SHA2 of the plaintext" do
      keypair = Lotus::Crypto.new_keypair

      Digest::SHA2.any_instance.expects(:digest)
                               .with("payload")
                               .returns("SHA2")

      matcher = /\x20SHA2$/
      RSA::KeyPair.new.expects(:decrypt).with(regexp_matches(matcher))

      Lotus::Crypto.emsa_sign("payload", keypair.private_key)
    end
  end

  describe "emsa_verify" do
    it "should return true when the message matches" do
      keypair = Lotus::Crypto.new_keypair

      valid_signature =
        "\x00\x01\x00\x30\x31\x30\x0d\x06\x09\x60\x86\x48\x01\x65\x03\x04\x02\x01\x05\x00\x04\x20SHA2"

      valid_signature.force_encoding('binary')

      signature = Lotus::Crypto.emsa_sign("payload", keypair.private_key)

      RSA::KeyPair.new.expects(:encrypt)
                      .with(signature)
                      .returns(valid_signature)

      Lotus::Crypto.emsa_verify("payload", signature, keypair.public_key)
                   .must_equal true
    end

    it "should return false when the message does not match" do
      keypair = Lotus::Crypto.new_keypair

      bogus_signature =
        "\x00\x01\x00\x30\x31\x30\x0d\x06\x09\x60\x86\x48\x01\x65\x03\x04\x02\x01\x05\x00\x04\x20BOGUS"

      bogus_signature.force_encoding('binary')

      signature = Lotus::Crypto.emsa_sign("payload", keypair.private_key)

      RSA::KeyPair.new.expects(:encrypt)
                      .with(signature)
                      .returns(bogus_signature)

      Lotus::Crypto.emsa_verify("payload", signature, keypair.public_key)
                   .must_equal false
    end
  end

  describe "decrypt" do
    it "should relegate to RSA::KeyPair" do
      keypair = Lotus::Crypto.new_keypair

      RSA::KeyPair.new.expects(:decrypt)
                      .with("payload")
                      .returns("OBSCURED")

      Lotus::Crypto.decrypt(keypair.private_key, "payload")
                   .must_equal "OBSCURED"
    end
  end

  describe "encrypt" do
    it "should relegate to RSA::KeyPair" do
      keypair = Lotus::Crypto.new_keypair

      RSA::KeyPair.new.expects(:encrypt)
                      .with("payload")
                      .returns("OBSCURED")

      Lotus::Crypto.encrypt(keypair.public_key, "payload")
                   .must_equal "OBSCURED"
    end
  end
end
