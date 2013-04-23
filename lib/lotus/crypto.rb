module Lotus
  module Crypto
    require 'openssl'
    require 'rsa'
    require 'base64'

    KeyPair = Struct.new(:public_key, :private_key)

    # Generate a new RSA keypair with the given bitlength.
    def self.new_keypair(bits = 2048)
      keypair = KeyPair.new

      key = RSA::KeyPair.generate(bits)

      public_key = key.public_key
      m = public_key.modulus
      e = public_key.exponent

      modulus = ""
      until m == 0 do
        modulus << [m % 256].pack("C")
        m >>= 8
      end
      modulus.reverse!

      exponent = ""
      until e == 0 do
        exponent << [e % 256].pack("C")
        e >>= 8
      end
      exponent.reverse!

      keypair.public_key = "RSA.#{Base64::urlsafe_encode64(modulus)}.#{Base64::urlsafe_encode64(exponent)}"

      tmp_private_key = key.private_key
      m = tmp_private_key.modulus
      e = tmp_private_key.exponent

      modulus = ""
      until m == 0 do
        modulus << [m % 256].pack("C")
        m >>= 8
      end
      modulus.reverse!

      exponent = ""
      until e == 0 do
        exponent << [e % 256].pack("C")
        e >>= 8
      end
      exponent.reverse!

      keypair.private_key = "RSA.#{Base64::urlsafe_encode64(modulus)}.#{Base64::urlsafe_encode64(exponent)}"

      keypair
    end

    # Creates an EMSA signature for the given plaintext and key.
    def self.emsa_sign(text, private_key)
      private_key = generate_key(private_key) unless private_key.is_a? RSA::Key

      signature = self.emsa_signature(text, private_key)

      self.decrypt(private_key, signature)
    end

    # Verifies an existing EMSA signature.
    def self.emsa_verify(text, signature, public_key)
      # RSA encryption is needed to compare the signatures
      public_key = generate_key(public_key) unless public_key.is_a? RSA::Key

      # Get signature to check
      emsa = self.emsa_signature(text, public_key)

      # Get signature in payload
      emsa_signature = self.encrypt(public_key, signature)

      # RSA gem drops leading 0s since it does math upon an Integer
      # As a workaround, I check for what I expect the second byte to be (\x01)
      # This workaround will also handle seeing a \x00 first if the RSA gem is
      # fixed.
      if emsa_signature.getbyte(0) == 1
        emsa_signature = "\x00#{emsa_signature}"
      end

      # Does the signature match?
      # Return the result.
      emsa_signature == emsa
    end

    # Decrypts the given data with the given private key.
    def self.decrypt(private_key, data)
      private_key = generate_key(private_key) unless private_key.is_a? RSA::Key
      keypair = generate_keypair(nil, private_key)
      keypair.decrypt(data)
    end

    # Encrypts the given data with the given public key.
    def self.encrypt(public_key, data)
      public_key = generate_key(public_key) unless public_key.is_a? RSA::Key
      keypair = generate_keypair(public_key, nil)
      keypair.encrypt(data)
    end

    private

    # :nodoc:
    def self.emsa_signature(text, key)
      modulus_byte_count = key.modulus.size

      plaintext = Digest::SHA2.new(256).digest(text)

      prefix = "\x30\x31\x30\x0d\x06\x09\x60\x86\x48\x01\x65\x03\x04\x02\x01\x05\x00\x04\x20"
      padding_count = modulus_byte_count - prefix.bytes.count - plaintext.bytes.count - 3

      padding = ""
      padding_count.times do
        padding = padding + "\xff"
      end

      "\x00\x01#{padding}\x00#{prefix}#{plaintext}"
    end

    # :nodoc:
    def self.generate_key(key_string)
      return nil unless key_string

      key_string.match /^RSA\.(.*?)\.(.*)$/

      modulus = decode_key($1)
      exponent = decode_key($2)

      RSA::Key.new(modulus, exponent)
    end

    def self.generate_keypair(public_key, private_key)
      RSA::KeyPair.new(private_key, public_key)
    end

    # :nodoc:
    def self.decode_key(encoded_key_part)
      modulus = Base64::urlsafe_decode64(encoded_key_part)
      modulus.bytes.inject(0) {|num, byte| (num << 8) | byte }
    end
  end
end
