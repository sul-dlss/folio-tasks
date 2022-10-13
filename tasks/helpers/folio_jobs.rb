# frozen_string_literal: true

# Class to multi-thread loading data to folio
module FolioJobs
  def batch_post_orders(file_dir, pool_size)
    jobs = Queue.new
    Dir.each_child(file_dir) { |file| jobs.push("#{file_dir}/#{file}") }
    command = 'orders_post(JSON.parse(File.read(entity)))'
    do_work(pool_size, jobs, command)
  end

  def batch_put_orders(file_dir, pool_size)
    jobs = Queue.new
    Dir.each_child(file_dir) { |file| jobs.push("#{file_dir}/#{file}") }
    command = 'orders_put(JSON.parse(File.read(entity))["id"], JSON.parse(File.read(entity)))'
    do_work(pool_size, jobs, command)
  end

  def batch_delete_orders(pool_size)
    jobs = Queue.new
    AcquisitionsUuidsHelpers.orders.each_value { |uuid| jobs.push(uuid) }
    command = 'orders_delete(entity)'
    do_work(pool_size, jobs, command)
  end

  def do_work(pool_size, jobs, command)
    execute_threads(
      Array.new(pool_size) do |n|
        Thread.new do
          while (entity = jobs.pop(true))
            puts "worker #{n} processing entity #{entity}"
            instance_eval(command)
          end
        rescue ThreadError => e
          puts e unless jobs.empty?
        end
      end
    )
  end

  def execute_threads(workers)
    workers.map(&:join) # execute the threads
    workers.each(&:exit) if workers.each(&:stop?) # kill threads when done
  end
end
