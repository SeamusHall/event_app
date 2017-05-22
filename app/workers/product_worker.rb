class ProductWorker < AttachmentUploader
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(product_id,attach_index)
    video = Product.find(product_id).attachments[attach_index]
    path = video.path
    output = "/tmp/#{Time.now.getutc.to_f.to_s.delete('.')}.mp4"
    #_command = `ffmpeg -i #{path} -f mp4 -vcodec h264 -acodec aac -strict -2 #{output}`
    _command = `ffmpeg -i #{path} -c:v libx264 -crf 19 -preset slow -c:a aac -b:a 192k -ac 2 #{output}`
    if $?.to_i == 0
      @file = File.open(output, 'r')
      Product.find(product_id).save
      FileUtils.rm(output)
    else
      raise $?
    end
  end
end
