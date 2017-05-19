class ThumbnailWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(product_id,attach_index)
    video = Product.find(product_id).attachments[attach_index]
    output = "/tmp/#{Time.now.getutc.to_f.to_s.delete('.')}.png"
    _command = `ffmpeg -i #{video.path} -ss 00:00:01.000 -vframes 1 #{output}`
    if $?.to_i == 0
      video.thumbnail = File.open(output, 'r')
      FileUtils.rm(output)
    else
      raise $?
    end
  end
end
