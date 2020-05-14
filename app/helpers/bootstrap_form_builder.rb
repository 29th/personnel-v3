class BootstrapFormBuilder < ActionView::Helpers::FormBuilder
  def errors(method)
    object.errors.full_messages_for(method).map { |m| help_block(m) }.join.html_safe
  end

  def help_block(message)
    %Q(<span class="help-block">#{message}</span>).html_safe
  end

  def group(method, &block)
    if object.errors.has_key?(method)
      class_names = "form-group has-error"
    else
      class_names = "form-group"
    end

    content = @template.capture(&block)

    %Q(<div class="#{class_names}">#{content}</div>).html_safe
  end

  def label(method, text = nil, options = {}, &block)
    super(method, text, insert_class("control-label", options), &block)
  end

  %w(text_field email_field password_field).each do |selector|
    class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      def #{selector}(method, options = {})
        super(method, insert_class("form-control", options))
      end
    RUBY_EVAL
  end

  def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
    super(method, collection, value_method, text_method, options, insert_class("form-control", html_options))
  end

  def submit(value = nil, options = {})
    super(value, insert_class("btn btn-primary", options))
  end

  private

  def insert_class(class_name, options)
    output = options.dup
    output[:class] = ((output[:class] || "") + " #{class_name}").strip
    output
  end
end
