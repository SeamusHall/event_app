module Admin
  class AttachmentsController < AdminController
    before_action :set_product

    def create
      add_attachments(attachments_params[:attachments])
      if @product.save
        redirect_to :back, notice: 'Attachment was sucessfully added to product.'
      else
        flash[:error] = "Failed uploading attachments"
        redirect_to :back
      end
    end

    def destroy
      delete_attachments(attachments_params[:product_id])
      if @product.save
        redirect_to :back, notice: 'Attachment was sucessfully deleted from product.'
      else
        flash[:error] = "Failed to delete attachment"
        redirect_to :back
      end
    end

    private

      def set_product
        @product = Product.find(params[:product_id])
      end

      def add_attachments(new_attachments)
        attachments = @product.attachments     # copy the old attachments
        attachments += new_attachments         # add old attachments with new ones
        @product.attachments = attachments     # assign back
      end

      def remove_image_at_index(index)
        remain_attach = @product.attachments            # copy the array
        deleted_attach = remain_attach.delete_at(index) # delete the attachment at index
        deleted_attach.try(:remove!)                    # delete attachment from S3
        @product.attachments = remain_attach            # re-assign back
      end

      def attachments_params
        params.require(:product).permit({attachments: []})
      end
  end
end
