require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/admin/limits' do

    def create_request(session_data = get_session_data, &block)
      klass.new(session_data, &block)
    end
    
    
    def get_session_data
      session.send :auth_info
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'admin', 'limits.rb')
    end


    def session
      unless @session
        @session = Aviator::Session.new(
                     config_file: Environment.path,
                     environment: 'openstack_admin'
                   )
        @session.authenticate
      end
      
      @session
    end
    

    validate_attr :anonymous? do
      klass.anonymous?.must_equal false
    end


    validate_attr :api_version do
      klass.api_version.must_equal :v2
    end


    validate_attr :body do
      request = create_request

      klass.body?.must_equal true
      request.body?.must_equal true 
      request.body.wont_be_nil
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :admin
    end


    validate_attr :headers do
      session_data = get_session_data

      headers = { 'X-Auth-Token' => session_data[:access][:token][:id] }

      request = create_request(session_data)

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :get
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:tenant_id]
    end


    validate_attr :url do
      session_data = get_session_data
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:adminURL] }/limits"
      request      = klass.new(session_data)

      request.url.must_equal url
    end

    validate_response 'params are valid' do
      service = session.identity_service

      response = service.request :limits do |params|
        params[:tenant_id] = ''
      end

      response.status.must_equal 200
      response.headers.wont_be_nil
      response.body.wont_be_nil
      response.body[:limits].length.wont_equal 0

      response.body[:limits].each do |host|
        host[:zone].must_equal 'nova'
      end

    end


  end

end

