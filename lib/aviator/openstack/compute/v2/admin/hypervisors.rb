module Aviator

  define_request :hypervisors, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://api.openstack.org/api-ref-compute-v2-ext.html#ext-os-hypervisors'

    param :detail, required: false

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      url = "#{ base_url }/os-hypervisors"

      filters = []

      if optional_params.has_key?('detail')
        if params['detail']
          url += "/#{detail}"
        end
      end

      url
    end

  end

end

