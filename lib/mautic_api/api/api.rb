module MauticApi
  
  class Api
    
    ENDPOINT = ''
    BASE_API_ENDPOINT = 'api'

    def endpoint
      self.class::ENDPOINT
    end
    
    def base_api_endpoint
      self.class::BASE_API_ENDPOINT
    end
    
    def initialize access_token
      @access_token = access_token
    end

    def action_not_supported action
      return {
        error: {
          code: 500,
          message: "#{action} is not supported at this time."
        }
      }
    end
    
    # Make the API request
    #
    # @param string $endpoint
    # @param array  $parameters
    # @param string $method
    #
    # @return array|mixed
    
    def make_request endpoint, parameters = {}, method = :get
    
      begin
        
        if method == :get
          response = @access_token.request(method, "/#{self.base_api_endpoint}/#{endpoint}?#{parameters.to_query}")
        else
          response = @access_token.request(method, "/#{self.base_api_endpoint}/#{endpoint}", parameters.as_json)
        end
        
        json = JSON.parse(response.body)
        
        unless json.is_a?(Hash) 
          return {
            error: {
              code: 500,
              endpoint: "#{self.base_api_endpoint}/#{endpoint}",
              message: response
            }
          }
        end
          
        if json['error'].present? && json['error_description'].present?
          message = "#{json['error']}: #{json['error_description']}"
          return {
            error: {
              code: 403,
              endpoint: "#{self.base_api_endpoint}/#{endpoint}",
              message: message
            }
          }
        end
        
        return json
        
      rescue Exception => e
        
        return {
          error: {
            code: 500,
            endpoint: "#{self.base_api_endpoint}/#{endpoint}",
            message: e.message,
            backtrace: e.backtrace.join("\n")  
          }
        }
        
      end
      
    end
        
    # Get a single item
    #
    # @param int $id
    #
    # @returnarray|mixed
    
    def get id
      return make_request("#{self.endpoint}/#{id}")
    end

    # Get a list of items
    #
    # @param string $search
    # @param int    $start
    # @param int    $limit
    # @param string $orderBy
    # @param string $orderByDir
    # @param bool   $publishedOnly
    #
    # @return array|mixed
    
    def get_list search = '', start = nil, limit = nil, order_by = nil, order_by_dir = nil, published_only = false
      
      parameters = {}
      
      args = ['search', 'start', 'limit', 'order_by', 'order_by_dir', 'published_only']

      args.each do |arg|
        parameters[arg.to_sym] = (eval arg) if (eval arg).present?
      end

      return make_request(self.endpoint, parameters)
    end

    
    # Proxy function to getList with $publishedOnly set to true
    #
    # @param string $search
    # @param int    $start
    # @param int    $limit
    # @param string $orderBy
    # @param string $orderByDir
    #
    # @return array|mixed
    
    def get_published_list search = '', start = nil, limit = nil, order_by = nil, order_by_dir = nil
      return get_list(search, start, limit, order_by, order_by_dir, true)
    end

    
    # Create a new item (if supported)
    #
    # @param array $parameters
    #
    # @return array|mixed
    
    def create parameters
      return make_request("#{self.endpoint}/new", parameters, :post)
    end
    
    # Edit an item with option to create if it doesn't exist
    #
    # @param int   $id
    # @param array $parameters
    # @param bool  $createIfNotExists = false
    #
    # @return array|mixed
  
    def edit(id, parameters, create_if_not_exists = false)
      method = create_if_not_exists ? :put : :patch
      return make_request("#{self.endpoint}/#{id}/edit", parameters, method)
    end

    # Delete an item
    #
    # @param $id
    #
    # @return array|mixed
    
    def delete id
      return make_request("#{self.endpoint}/#{id}/delete", {}, :delete)
    end
  
  end
  
end
