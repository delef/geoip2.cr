module GeoIP2
  # The address you were looking up was not found
  class AddressNotFoundError < Exception
  end

  # There was a problem authenticating the request
  class AuthenticationError < Exception
  end

  # There was an exception when making your HTTP request
  class HTTPError < Exception
  end

  # The request was invalid
  class InvalidRequestError < Exception
  end

  # Your account is out of funds for the service queried
  class OutOfQueriesError < Exception
  end

  # Your account does not have permission to access this service
  class PermissionRequiredError < Exception
  end
end

