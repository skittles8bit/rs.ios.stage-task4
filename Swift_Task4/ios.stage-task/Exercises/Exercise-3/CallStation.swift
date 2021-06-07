import Foundation

final class CallStation {
    var usersSet: Set<User> = []
    var callsDic: [CallID: Call] = [:]
    var currentCalls: [CallID: Call] = [:]
}

extension User: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension CallStation: Station {
    func users() -> [User] {
        Array(usersSet)
    }
    
    func add(user: User) {
        usersSet.insert(user)
    }
    
    func remove(user: User) {
        usersSet.remove(user)
        
        if let currentCall = currentCall(user: user) {
            let call = Call(id: currentCall.id,
                            incomingUser: currentCall.incomingUser,
                            outgoingUser: currentCall.outgoingUser,
                            status: .ended(reason: .error))
            
            currentCalls[currentCall.incomingUser.id] = nil
            currentCalls[currentCall.outgoingUser.id] = nil
            callsDic[currentCall.id] = call
        }
    }
    
    func execute(action: CallAction) -> CallID? {
        switch action {
            case let .start(from: fromUser, to: toUser):
                if usersSet.contains(fromUser) {
                    if currentCall(user: toUser) != nil || currentCall(user: fromUser) != nil {
                        let call = Call(id: CallID(),
                                        incomingUser: toUser,
                                        outgoingUser: fromUser,
                                        status: .ended(reason: .userBusy))
                        
                        callsDic[call.id] = call
                        
                        return call.id
                    }
                    
                    if !usersSet.contains(toUser) {
                        let call = Call(id: CallID(),
                                        incomingUser: toUser,
                                        outgoingUser: fromUser,
                                        status: .ended(reason: .error))
                        
                        callsDic[call.id] = call
                        
                        return call.id
                    }
                    
                    let call = Call(id: CallID(), incomingUser: toUser, outgoingUser: fromUser, status: .calling)
                    
                    callsDic[call.id] = call
                    currentCalls[fromUser.id] = call
                    currentCalls[toUser.id] = call
                    
                    return call.id
                }
            case let .answer(from: user):
                if let currentCall = currentCalls[user.id], currentCall.incomingUser == user, currentCall.status == .calling {
                    let call = Call(id: currentCall.id,
                                    incomingUser: currentCall.incomingUser,
                                    outgoingUser: currentCall.outgoingUser,
                                    status: .talk)
                    
                    callsDic[currentCall.id] = call
                    currentCalls[currentCall.incomingUser.id] = call
                    currentCalls[currentCall.outgoingUser.id] = call
                    
                    return call.id
                }
            case let .end(from: user):
                if let currentCall = currentCalls[user.id] {
                    currentCalls[currentCall.incomingUser.id] = nil
                    currentCalls[currentCall.outgoingUser.id] = nil
                    
                    let status: CallStatus = currentCall.status == .talk ? .ended(reason: .end) : .ended(reason: .cancel)
                    let call = Call(id: currentCall.id,
                                    incomingUser: currentCall.incomingUser,
                                    outgoingUser: currentCall.outgoingUser,
                                    status: status)
                    
                    callsDic[currentCall.id] = call
                    
                    return call.id
                }
            }
        
        return nil
    }
    
    func calls() -> [Call] {
        Array(callsDic.values)
    }
    
    func calls(user: User) -> [Call] {
        calls().filter { call in
            call.incomingUser == user || call.outgoingUser == user
        }
    }
    
    func call(id: CallID) -> Call? {
        callsDic[id]
    }
    
    func currentCall(user: User) -> Call? {
        currentCalls[user.id]
    }
}
