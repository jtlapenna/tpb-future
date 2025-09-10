class ProductsMailer < ApplicationMailer
  def share(product, email)
    return if email.blank?
    return if product.share_email_template.blank?
    return unless product.store.enabled_share_email_product?
    return if product.brand_for_catalog.blank?

    subject = "A note from #{product.brand_for_catalog.name}"

    mail to: email,
         subject: subject,
         content_type: 'text/html',
         body: product.share_email_template.html_safe
  end
end
