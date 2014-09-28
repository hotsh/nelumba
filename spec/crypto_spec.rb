require_relative 'helper'
require_relative '../lib/nelumba/crypto.rb'

describe Nelumba::Crypto do
  # To make things faster, we can stub key generation:
  # But we will _actually_ generate one good key for the test run
  before do
    $__key ||= RSA::KeyPair.generate(2048)
    RSA::KeyPair.stubs(:generate).returns($__key)
  end

  describe "new_keypair" do
    it "should return a KeyPair structure" do
      Nelumba::Crypto.new_keypair.class.must_equal Nelumba::Crypto::KeyPair
    end

    it "should return a KeyPair structure with an RSA public key" do
      Nelumba::Crypto.new_keypair.public_key.must_match /^RSA\.(.*?)\.(.*)$/
    end

    it "should return a KeyPair structure with an RSA private key" do
      Nelumba::Crypto.new_keypair.private_key.must_match /^RSA\.(.*?)\.(.*)$/
    end

    it "should relegate to RSA::KeyPair" do
      ret = RSA::KeyPair.generate(4)
      RSA::KeyPair.expects(:generate).returns(ret)

      Nelumba::Crypto.new_keypair
    end
  end

  describe "emsa_sign" do
    it "should return a string with the EMSA prefix" do
      keypair = Nelumba::Crypto.new_keypair

      sequence = "^\x00\x01\xFF*?\x00\x30\x31\x30\x0d\x06\x09\x60\x86\x48\x01\x65\x03\x04\x02\x01\x05\x00\x04\x20"
      matcher = Regexp.new(sequence, nil, 'n')

      RSA::KeyPair.any_instance.expects(:decrypt).with(regexp_matches(matcher))

      Nelumba::Crypto.emsa_sign "payload", keypair.private_key
    end

    it "should return the result of decryption with the private key" do
      keypair = Nelumba::Crypto.new_keypair

      # This is a heavily implementation driven test to avoid testing RSA

      Nelumba::Crypto.stubs(:generate_key).with(keypair.private_key).returns("keypair")
      Nelumba::Crypto.stubs(:emsa_signature).with("payload", "keypair").returns("signature")
      Nelumba::Crypto.stubs(:decrypt).with("keypair", "signature").returns("DECRYPTED")

      Nelumba::Crypto.emsa_sign("payload", keypair.private_key)
                     .must_equal "DECRYPTED"
    end

    it "should end the signature with the SHA2 of the plaintext" do
      keypair = Nelumba::Crypto.new_keypair

      Digest::SHA2.any_instance.expects(:digest)
                               .with("payload")
                               .returns("SHA2")

      matcher = /\x20SHA2$/
      RSA::KeyPair.any_instance.expects(:decrypt).with(regexp_matches(matcher))

      Nelumba::Crypto.emsa_sign("payload", keypair.private_key)
    end
  end

  describe "emsa_verify" do
    it "should return true when the message matches" do
      keypair = Nelumba::Crypto.new_keypair

      signature = Nelumba::Crypto.emsa_sign("payload", keypair.private_key)

      Nelumba::Crypto.emsa_verify("payload", signature, keypair.public_key)
                     .must_equal true
    end

    it "should return false when the message does not match" do
      keypair = Nelumba::Crypto.new_keypair

      bogus_signature =
        "\x00\x01\x00\x30\x31\x30\x0d\x06\x09\x60\x86\x48\x01\x65\x03\x04\x02\x01\x05\x00\x04\x20BOGUS"

      bogus_signature.force_encoding('binary')

      signature = Nelumba::Crypto.emsa_sign("payload", keypair.private_key)

      RSA::KeyPair.any_instance.expects(:encrypt)
                               .with(signature)
                               .returns(bogus_signature)

      Nelumba::Crypto.emsa_verify("payload", signature, keypair.public_key)
                     .must_equal false
    end
  end

  describe "decrypt" do
    it "should relegate to RSA::KeyPair" do
      keypair = Nelumba::Crypto.new_keypair

      RSA::KeyPair.any_instance.expects(:decrypt)
                               .with("payload")
                               .returns("OBSCURED")

      Nelumba::Crypto.decrypt(keypair.private_key, "payload")
                     .must_equal "OBSCURED"
    end
  end

  describe "encrypt" do
    it "should relegate to RSA::KeyPair" do
      keypair = Nelumba::Crypto.new_keypair

      RSA::KeyPair.any_instance.expects(:encrypt)
                               .with("payload")
                               .returns("OBSCURED")

      Nelumba::Crypto.encrypt(keypair.public_key, "payload")
                     .must_equal "OBSCURED"
    end
  end
end
