import sys
import socket
from thread_pool import *
import select
from collections import defaultdict


def recv_all(sock):
    read = ''
    try:
        data = sock.recv(8196)
        read += data
    except socket.error, e:
        print "socket error: {}".format(e)
    return read


class ChatRoom(object):

    def __init__(self):
        self.name = name
        self.ref = ref


class Client(object):
    
    def __init__(self):
        self.sock = sock
        self.addr = addr
        self.name = name
        self.uid = uid


class Server(object):

    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.threads = ThreadPool(20)
        self.connections = [] # top-level list of connected sockets, should be 1-1 with [user.sock for user in self.users]
        self.chat_rooms = {} # ref -> chat room obj
        self.users = {} # uid -> user obbj
        self.userc = 0
        self.roomc = 0

    def run(self):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.bind((self.host, self.port))
        self.sock.listen(5) # 5 is the general maximum on OSes
        print "Starting server, listening on {}:{}".format(self.host, self.port)

        while True:
            try:
                read_sockets, _, _ = select.select(self.connections + [self.sock],[],[])
                for sock in read_sockets:
                    if sock is self.sock:
                        self.process_new_connection()
                    else:
                        self._dispatch_thread(self._process_message, sock)
            except select.error:
                break

    def _process_new_connection(self):
        sock, addr = self.sock.accept()

        newbie = Client(sock, addr, "", self.userc)
        self.users[newbie.uid] = newbie
        self.userc += 1

        # create Client object and other state etc.
        self._dispatch_thread(self._process_message, sock)


    def _dispatch_thread(self, f, sock):
        self.threads.add_task(f, self, sock)


    def _process_message(self, sock):
        data = recv_all(sock)

        msg = data.splitlines()
        msg = map(lambda s: s.split(), msg)

        if msg[0][0] == "JOIN_CHATROOM:":
            room = msg[0][1]
            name = msg[3][1]


        elif msg[0][0] == "LEAVE_CHATROOM:":
            ref = msg[0][1]
            uid = msg[1][1]
            name = msg[2][1]

            if ref not in self.chat_rooms:
                sock.write(error(2, "Unknown chat room: {}".format(ref)))
                return

            if uid not in self.users:
                sock.write(error(3, "Unknown user Join ID: {}".format(uid)))
                return

            if name != self.users[uid].name:
                sock.write(error(5, "User name: {} does not match username for user: {} ({})".format(name, uid, self.users[uid].name)))
                return

            if self.chat_rooms[ref].users.pop(uid, False):
                sock.write(left(ref, uid))
            else:
                sock.write(error(4, "User: {} not in room: {}".format(uid, ref)))
                return



        elif msg[0][0] == "DISCONNECT:":
            pass
        elif msg[0][0] == "CHAT:":
            ref = msg[0][1]
            uid = msg[1][1]
            name = msg[2][1]
            message = msg[3][1]

            if ref not in self.chat_rooms:
                sock.write(error(2, "Unknown chat room: {}".format(ref)))
                return

            if uid not in self.users:
                sock.write(error(3, "Unknown user Join ID: {}".format(uid)))
                return

            if uid not in self.chat_rooms[ref].users:
                sock.write(error(4, "User: {} not in room: {}".format(uid, ref)))
                return

            if name != self.users[uid].name:
                sock.write(error(5, "User name: {} does not match username for user: {} ({})".format(name, uid, self.users[uid].name)))
                return  

            self._broadcast(ref, name, message)
            
        else:
            sock.write(error(1, "Unknown chat command"))



    def _broadcast(self, ref, name, msg):
        if ref not in self.chat_rooms:
            print "Room ref: {} does not exist".format(ref)
            return 

        for user in self.chat_rooms[ref].users:
            user.sock.send(message(ref, name, msg))

    def shutdown(self):
        self.threads.end()
        for conn in self.connections():
            conn.close()





def error(code, msg):
    return "ERROR_CODE: {}\nERROR_DESCRIPTION: {}".format(code, msg) 

def message(ref, name, msg):
    return "CHAT: {}\nCLIENT_NAME: {}\nMESSAGE: {}".format(ref, name, msg)

def joined(room, ref, server, port, uid):
    return "JOINED_CHATROOM: {}\nSERVER_IP: {}\nPORT: {}\nROOM_REF: {}\nJOIN_ID: {}".format(room,
                                                                                            server,
                                                                                            port,
                                                                                            ref,
                                                                                            uid)

def left(ref, id):
    return "LEFT_CHATROOM: {}\nJOIN_ID: {}".format(ref, id)


def main():
    server = Server("0.0.0.0", 12345)
    server.run()

if __name__ == '__main__':
    main()