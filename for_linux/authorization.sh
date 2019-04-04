#!/bin/bash
REMOTE_HOST=172.18.0.11
PORT=22
ssh-keygen -t rsa
ssh-copy-id -i $HOME/.ssh/id_rsa.pub "-p $PORT $USER@$REMOTE_HOST"
ssh $USER@$REMOTE_HOST -p $PORT
