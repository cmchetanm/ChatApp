# frozen_string_literal: true

# User Serializer
class UserSerializer < ActiveModel::Serializer
  attributes :id, :email
end