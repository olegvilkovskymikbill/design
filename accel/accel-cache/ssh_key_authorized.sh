#!/bin/bash
# Выполнять от root, на клиенте сделать учетку bill
REMOTE_HOST=10.10.10.10
PORT=2280
USER=bill
ssh-keygen -t rsa
echo $HOME
ssh-copy-id -i $HOME/.ssh/id_rsa.pub "-p $PORT $USER@$REMOTE_HOST"
echo $USER
ssh $USER@$REMOTE_HOST -p $PORT
