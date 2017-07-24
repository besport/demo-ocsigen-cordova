(* Service for this demo *)
let%server service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["share-intent"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

(* Make service available on the client *)
let%client service = ~%service

(* Name for demo menu *)
let%shared name () = [%i18n S.share_intent_button]

(* Class for the page containing this demo (for internal use) *)
let%shared page_class = "os-page-share-intent"


(*function to send the intent of an image*)
let%client send_intent_image v =
  let s1 = object%js
    val action = Js.string "android.intent.action.SEND"
    val type_ = Js.string "image/*"
    val extras = Js.Unsafe.obj [|"android.intent.extra.STREAM", Js.Unsafe.inject (Js.string v)|]
    val requestCode = 1
  end in
  Js.Unsafe.global##.plugins##.intent##.startActivity s1
    (Js.wrap_callback (fun () ->  Firebug.console##log (Js.string "StartActivity success")))
    (Js.wrap_callback (fun () ->
       Firebug.console##log (Js.string "StartActivity failure")))


(*function to send the intent of a text*)
let%client send_intent_text v =
  let w = "<p>" ^ v ^ "</p>" in
  let s1 = object%js
    val action = Js.string "android.intent.action.SEND"
    val type_ = Js.string "text/html"
    val extras = Js.Unsafe.obj [|"android.intent.extra.TEXT", Js.Unsafe.inject (Js.string w)|]
    val requestCode = 1
  end in
  Js.Unsafe.global##.plugins##.intent##.startActivity s1
    (Js.wrap_callback (fun () ->  Firebug.console##log (Js.string "StartActivity success")))
    (Js.wrap_callback (fun () ->
       Firebug.console##log (Js.string "StartActivity failure")))

(*function to send the intent of a video*)
let%client send_intent_video v =
  let s1 = object%js
    val action = Js.string "android.intent.action.SEND"
    val type_ = Js.string "video/*"
    val extras = Js.Unsafe.obj [|"android.intent.extra.STREAM", Js.Unsafe.inject (Js.string v)|]
    val requestCode = 1
  end in
  Js.Unsafe.global##.plugins##.intent##.startActivity s1
    (Js.wrap_callback (fun () ->  Firebug.console##log (Js.string "StartActivity success")))
    (Js.wrap_callback (fun () ->
       Firebug.console##log (Js.string "StartActivity failure")))


let%shared button msg f =
  let btn =
    Eliom_content.Html.
      (D.button ~a:[D.a_class ["button"]] [D.pcdata msg])
  in
  ignore [%client
    ((Lwt.async @@ fun () ->
      Lwt_js_events.clicks
        (Eliom_content.Html.To_dom.of_element ~%btn)
        (fun _ _ -> ~%f ()))
     : unit)
  ];
  btn

let%shared make_form msg f =
  let inp = Eliom_content.Html.D.Raw.input ()
  and btn = Eliom_content.Html.(
    D.button ~a:[D.a_class ["button"]] [D.pcdata msg]
  ) in
  ignore [%client
    ((Lwt.async @@ fun () ->
      let btn = Eliom_content.Html.To_dom.of_element ~%btn
      and inp = Eliom_content.Html.To_dom.of_input ~%inp in
      Lwt_js_events.clicks btn @@ fun _ _ ->
      let v = Js.to_string inp##.value in
      let%lwt () = ~%f v in
      inp##.value := Js.string "";
      Lwt.return ())
     : unit)
  ];
  Eliom_content.Html.D.div [inp; btn]

(* Page for this demo *)
let%shared page () =


  let inp =
    make_form "share an image"
      [%client
        ((fun v ->
           if Essai_contacts.is_client_app () then
             (Cordova_intent.addEventListener "deviceReady" @@ fun () ->
              send_intent_image v)
           else
             Eliom_lib.alert "You can't share an image from Ocsigen start: you need to be on the mobile app!";
           Lwt.return ()
         )
         : string -> unit Lwt.t)
      ]

  in

  let inp2 =
    make_form "share a text"
      [%client
        ((fun v ->
           if Essai_contacts.is_client_app () then
             (Cordova_intent.addEventListener "deviceReady" @@ fun () ->
              send_intent_text v)
           else
             Eliom_lib.alert "You can't share a text from Ocsigen start: you need to be on the mobile app!";
           Lwt.return ()
         )
         : string -> unit Lwt.t)
      ]
  in

  let inp3 =
    make_form "share a video"
      [%client
        ((fun v ->
           if Essai_contacts.is_client_app () then
             (Cordova_intent.addEventListener "deviceReady" @@ fun () ->
              send_intent_video v)
           else
             Eliom_lib.alert "You can't share a video from Ocsigen start: you need to be on the mobile app!";
           Lwt.return ()
         )
         : string -> unit Lwt.t)
      ]
  in




  Lwt.return Eliom_content.Html.[
    F.h1 [%i18n share_intent_button]
  ; F.p [F.pcdata [%i18n S.only_works_on_smartphone]]
  ; F.p [F.pcdata [%i18n S.share_intent_button_description]]
  ; inp
  ; F.p [F.pcdata [%i18n S.share_intent_button_description2]]
  ; inp2
  ; F.p [F.pcdata [%i18n S.share_intent_button_description3]]
  ; inp3
  ]
