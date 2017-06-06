module ApplicationHelper

  def text_icon(icon, options={})
    options[:color] ||= ''
    classes = []
    classes << "fa-#{icon.to_s.gsub(/\_/,'-')}"
    classes << options[:color].to_s.gsub(/\_/,'-') if options.key?(:color)
    classes << options[:class] if options.key?(:class)
    capture_haml do
      haml_tag :i, class: "fa #{classes.join(' ')}"
      if options.key?(:label)
        haml_tag :br
        haml_tag :span, options[:label]
      end
    end
  end

  def object_actions(*args)
    options = args.extract_options!
    object = args.shift
    acl_object = object.is_a?(Array) ? object.last : object
    html = []
    if args.any?
      args.each do |action|
        html << link_to(action.first, action.second)
      end
    end
    if can?(:read, acl_object) && !options[:skip_view]
      html << link_to(t('admin.show'), polymorphic_path(object))
    end
    if can?(:edit, acl_object) && !options[:skip_edit]
      edit_path = "edit_#{object.class.name.underscore}_path"
      html << link_to(t('admin.edit'), edit_polymorphic_path(object))#, "data-no-turbolink" => true)
    end
    if can?(:destroy, acl_object) && !options[:skip_destroy]
      options[:confirm] ||= 'Are you sure? This action cannot be undone!'
      html << link_to(t('admin.destroy'), object, method: :delete, "data-confirm" => options[:confirm] )
    end
    html.join(' | ').html_safe
  end

  def errors_for(object, dismissal=true)
    capture_haml do
      if object.errors.any?
        haml_tag :div, class: 'row' do
          haml_tag :div, class: 'col-sm-12' do
            haml_tag :div, class: 'errors' do
              haml_tag :div, class: 'alert alert-danger' do
                object_name = t("models.#{object.class.name.underscore.downcase}", default: object.class.name.titleize)
                if dismissal
                  haml_tag :a, '&times;'.html_safe, class: 'close', "data-dismiss" => "alert", "aria-label" => "close"
                end
                haml_tag :p, "#{pluralize(object.errors.count, 'error')} prohibited this #{object_name} from being saved"
                haml_tag :ul do
                  object.errors.full_messages.each do |error|
                    haml_tag :li, error
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def display_flash
    capture_haml do
      flash.each do |type, message|
        message_class = case type
        when 'notice'
          'success'
        when 'alert'
          'warning'
        when 'error'
          'danger'
        else
          'info'
        end
        haml_tag :div, class: "alert alert-#{message_class} fade in" do
          haml_tag :a, '&times;'.html_safe, class: 'close', "data-dismiss" => "alert", "aria-label" => "close"
          haml_concat message
        end
      end
    end
  end

  def markdown(text)
    renderer = Redcarpet::Render::HTML.new(filter_html: true, hard_wrap: true, link_attributes: { rel: 'nofollow', target: "_blank" }, fenced_code_blocks: true, prettify: true)
    markdown = Redcarpet::Markdown.new(renderer, { tables: true, autolink: true, superscript: true, space_after_headers: true, underline: true, highlight: true, quote: true, footnotes: true, disable_indented_code_blocks: true } )
    markdown.render(text).html_safe
  end
end
