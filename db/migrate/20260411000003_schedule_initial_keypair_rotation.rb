# frozen_string_literal: true

class ScheduleInitialKeypairRotation < ActiveRecord::Migration[8.1]
  def up
    # Bootstrap the perpetual key-rotation chain. Keypair.current returns the
    # most-recent keypair (creating one on-the-fly if none exists). We schedule
    # RotateKeypairJob to fire 60 days after that key was created, which is
    # 30 days before the default 90-day expiry.
    run_at = [ Keypair.current.created_at + RotateKeypairJob::ROTATION_INTERVAL, Time.current ].max
    RotateKeypairJob.set(wait_until: run_at).perform_later
  end

  def down
    # Removing the scheduled job is a no-op in migration rollback; the
    # delayed_job record will simply be left to run (or be cleaned up manually).
  end
end
