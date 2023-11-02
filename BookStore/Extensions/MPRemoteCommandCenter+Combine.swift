import MediaPlayer
import Combine

extension MPRemoteCommandCenter {
    
    enum MediaEvent: Equatable {
        
        case play
        case pause
        case seekBackward
        case seekForward
        case seekTo(Double)
    }
    
    func remoteCommandPublisher() -> AnyPublisher<MPRemoteCommandCenter.MediaEvent, Never> {
        Publisher(self)
            .eraseToAnyPublisher()
    }
}

fileprivate extension MPRemoteCommandCenter {
    
    private struct Publisher: Combine.Publisher {
        
        typealias Output = MPRemoteCommandCenter.MediaEvent
        typealias Failure = Never
        
        var center: MPRemoteCommandCenter
        
        init(_ center: MPRemoteCommandCenter) {
            self.center = center
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Publisher.Failure == S.Failure, Publisher.Output == S.Input {
            let subscription = MPRemoteCommandCenter.MediaEvent.Subscription(subscriber: subscriber, center: center)
            subscriber.receive(subscription: subscription)
        }
    }
}

fileprivate extension MPRemoteCommandCenter.MediaEvent {
    
    final class Subscription<SubscriberType: Subscriber>: Combine.Subscription where SubscriberType.Input == MPRemoteCommandCenter.MediaEvent, SubscriberType.Failure == Never {
        
        var center: MPRemoteCommandCenter? = nil
        private var subscriber: SubscriberType
        
        init(subscriber: SubscriberType, center: MPRemoteCommandCenter) {
            self.center = center
            self.subscriber = subscriber
            
            center.playCommand.addTarget { event in
                _ = subscriber.receive(.play)
                return .success
            }
            
            center.pauseCommand.addTarget { event in
                _ = subscriber.receive(.pause)
                return .success
            }
            
            center.skipForwardCommand.addTarget { event in
                _ = subscriber.receive(.seekForward)
                return .success
            }
            
            center.skipBackwardCommand.addTarget { event in
                _ = subscriber.receive(.seekBackward)
                return .success
            }
            
            center.changePlaybackPositionCommand.addTarget { event in
                if let changePlaybackPositionCommandEvent = event as? MPChangePlaybackPositionCommandEvent {
                    _ = subscriber.receive(.seekTo(changePlaybackPositionCommandEvent.positionTime))
                }
                
                return .success
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
            // We do nothing here as we only want to send events when they occur.
        }
        
        func cancel() {
            center?.playCommand.removeTarget(self)
            center?.pauseCommand.removeTarget(self)
            center?.skipForwardCommand.removeTarget(self)
            center?.skipBackwardCommand.removeTarget(self)
            center?.changePlaybackPositionCommand.removeTarget(self)
        }
    }
}
