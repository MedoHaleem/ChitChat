let Room = {
    init(socket, el) {
        let roomId = el.getAttribute("data-id")
        console.log(`element: ${el}, roomId: ${roomId}`)
        socket.connect()
        this.onReady(roomId, socket)
    },
    onReady(roomId, socket) {
        let msgContainer = document.getElementById("msg-container")
        let roomChannel = socket.channel("rooms:" + roomId)
        let msgInput = document.getElementById("msg-input")
        let postButton = document.getElementById("msg-submit")

        postButton.addEventListener("click", e => {
            roomChannel.push("new_chat",{body: msgInput.value})
            .receive("error", e => console.log(e))

            msgInput.value = ""
        })

        roomChannel.on("new_chat", resp => {
            console.log(resp)
            this.renderChat(msgContainer, resp)
        })
        roomChannel.join()
        .receive("ok", resp => console.log("Joined room channel ", resp))
        .receive("error", reason => console.log("failed to join ", reason))
    },
    esc(input){
        let div = document.createElement("div")
        div.appendChild(document.createTextNode(input))
        return div.innerHTML
    },
    renderChat(msgContainer, {body}) {
        let div = document.createElement("div")
        div.innerHTML = `
        <span>
        <strong>anon</strong>: ${this.esc(body)}
        </span>
        `
        msgContainer.appendChild(div)
        msgContainer.scrollTop = msgContainer.scrollHeight
    }
}

export default Room