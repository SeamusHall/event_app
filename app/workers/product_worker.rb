class ProductWorker < AttachmentUploader
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    process encode_video: [:mp4, callbacks: { after_transcode: :set_success } ]
  end
end
