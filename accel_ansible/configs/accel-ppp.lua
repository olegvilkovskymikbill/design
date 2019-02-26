#!lua
function macuser(pkt)
        return pkt:hdr('chaddr')
end

function opt82_v1(pkt)
        v,b1,b2,b3,b4,b5,b6=string.unpack(pkt:agent_remote_id(),'bbbbbb')
        return string.format("%02x:%02x:%02x:%02x:%02x:%02x", b1,b2,b3,b4,b5,b6)
end

function opt82_v2(pkt)
        if pkt:agent_circuit_id() ~= nil then
                if string.len(pkt:agent_remote_id()) ~= 0 then
                        v,b1,b2,b3,b4,b5,b6=string.unpack(pkt:agent_remote_id(),'bbbbbb')
                        return string.format("%02x:%02x:%02x:%02x:%02x:%02x", b1,b2,b3,b4,b5,b6)
                elseif (string.len(pkt:agent_remote_id()) == 0 and string.len(pkt:agent_circuit_id()) ~= 0) then
                        m1=string.sub(pkt:agent_circuit_id(),'-15','-14')
                        m2=string.sub(pkt:agent_circuit_id(),'-13','-12')
                        m3=string.sub(pkt:agent_circuit_id(),'-11','-10')
                        m4=string.sub(pkt:agent_circuit_id(),'-9','-8')
                        m5=string.sub(pkt:agent_circuit_id(),'-7','-6')
                        m6=string.sub(pkt:agent_circuit_id(),'-5','-4')
                        local username=m1..':'..m2..':'..m3..':'..m4..':'..m5..':'..m6
                        return username
                end
        else
                return pkt:hdr('chaddr')
        end
end
