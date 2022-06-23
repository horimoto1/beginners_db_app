create_list(:attachment, 5)

create_list(:attachment, 5, image: "480x320.png",
                            content_type: "image/png")

create_list(:attachment, 5, image: "480x320.gif",
                            content_type: "image/gif")

create_list(:attachment, 5, image: "rails.svg",
                            content_type: "image/svg+xml")
