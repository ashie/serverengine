#
# ServerEngine
#
# Copyright (C) 2012-2013 FURUHASHI Sadayuki
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
module ServerEngine

  class MultiThreadServer < MultiWorkerServer
    private

    def start_worker(wid)
      w = create_worker(wid)

      begin
        thread = Thread.new(&w.method(:main))
      ensure
        w.close
      end

      return WorkerMonitor.new(w, thread)
    end

    class WorkerMonitor
      def initialize(worker, thread)
        @worker = worker
        @thread = thread
      end

      def send_stop(stop_graceful)
        Thread.new { @worker.stop }
        nil
      end

      def send_reload
        Thread.new { @worker.reload }
      end

      #def join
      #  @thread.join
      #end

      def alive?
        @thread.alive?
      end
    end
  end

end
