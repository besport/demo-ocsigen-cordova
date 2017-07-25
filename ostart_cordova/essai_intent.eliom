(* Service for this demo *)
let%server service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["essai-intent"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

(* Make service available on the client *)
let%client service = ~%service

(* Name for demo menu *)
let%shared name () = [%i18n S.essai_intent_button]

(* Class for the page containing this demo (for internal use) *)
let%shared page_class = "os-page-essai-intent"


(* let%client l = ref [] *)
let%shared uri = ref ""
let%shared is_video = ref false
let%shared is_image = ref false
let%shared is_text = ref false


(*share a picture with the project and the link will be added to the list l*)
let%shared affect_to_uri () =


  let _ : unit Eliom_client_value.t =
    [%client

      let g (intent : Cordova_intent.intent) =
        match (Cordova_intent.action intent) with
        | "android.intent.action.SEND" ->
          if (Cordova_intent.type_ intent)="video/*" then
            begin
              uri:= (Cordova_intent.uri (Array.get (Cordova_intent.clipItems intent) 0 ));
              is_video := true;
              is_image := false;
              is_text := false;
            end
          else if (Cordova_intent.type_ intent)="image/*" then
            begin
              uri:= (Cordova_intent.uri (Array.get (Cordova_intent.clipItems intent) 0 ));
              is_image := true;
              is_video := false;
              is_text := false;
            end
          else if (Cordova_intent.type_ intent)="text/plain" || (Cordova_intent.type_ intent)="text/*" then
            begin
              uri:= (Cordova_intent.text_ (Array.get (Cordova_intent.clipItems intent) 0 ));
              is_image := false;
              is_video := false;
              is_text := true;
            end
          else
            begin
              is_image := false;
              is_video := false;
              is_text := false;
            end

        |"android.intent.action.SEND_TEXT" ->
          if (Cordova_intent.type_ intent)="text/plain" || (Cordova_intent.type_ intent)="text/*" then
          begin
            uri:= (Cordova_intent.text_ (Array.get (Cordova_intent.clipItems intent) 0 ));
            is_image := false;
            is_video := false;
            is_text := true;
          end
        (* | "android.intent.action.SEND_MULTIPLE" ->
          let my_array = Cordova_intent.clipItems intent in
          for i=0 to (Array.length my_array) - 1 do
            l := (Cordova_intent.uri (Array.get (Cordova_intent.clipItems intent) i ))::!l;
          done; *)
        | "android.intent.action.DEFAULT" ->
          is_image := false;
          is_video := false;
          is_text := false;
        | _ -> assert false


      in
      let f () =
        Cordova_intent.setNewIntentHandler g
      in
      Cordova_intent.addEventListener "deviceReady" f;
    ] in
  Lwt.return ()


let%shared display_uri () =
  Eliom_content.Html.F.table [
    Eliom_content.Html.F.tr [
      Eliom_content.Html.F.td [
        Eliom_content.Html.D.img
          ~a:[ Eliom_content.Html.F.a_style "width:100px; height:100px;" ] (* display:inline-block *)
          ~alt:"Ocsigen"
          ~src: (Eliom_content.Xml.uri_of_string !uri) ()]]
  ]





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

(* Page for this demo *)
let%shared page () =




  let button =

    Eliom_content.Html.D.Form.input
      ~a:[Eliom_content.Html.F.a_class ["button"]]
      ~input_type:`Submit
      ~value:[%i18n S.share_intent_popup]
      Eliom_content.Html.D.Form.string
  in

  ignore
    [%client (* This client section will be executed after the page is
                displayed by the browser. *)
      (Lwt.async (fun () ->
         (* Lwt_js_events.clicks returns a Lwt thread, which never terminates.
            We run it asynchronously. *)
         Lwt_js_events.clicks
           (Eliom_content.Html.To_dom.of_element ~%button)
           (fun _ _ ->
              let%lwt _ =
                Ot_popup.popup
                  ~close_button:[ Os_icons.F.close () ]
                  (fun _ ->
                     if !is_video then
                       begin
                         Lwt.return @@ Eliom_content.Html.F.table [
                           Eliom_content.Html.F.tr [
                             Eliom_content.Html.F.td[
                               Eliom_content.Html.D.video
                                 ~a:[ Eliom_content.Html.F.a_style
                                        "width:100px; height:100px;";
                                      Eliom_content.Html.F.a_loop ();
                                      Eliom_content.Html.F.a_autoplay ()] (* display:inline-block *)
                                 ~src:(Eliom_content.Xml.uri_of_string !uri)
                                 []
                             ]]
                         ]

                       end
                     else if !is_image then
                       begin
                         Lwt.return @@ Eliom_content.Html.F.table [
                           Eliom_content.Html.F.tr [
                             Eliom_content.Html.F.td[
                               Eliom_content.Html.D.img
                                 ~a:[ Eliom_content.Html.F.a_style "width:100px;height:100px;" ]
                                 ~alt:"Ocsigen"
                                 ~src: (Eliom_content.Xml.uri_of_string !uri) ()]]
                         ]
                       end

                     else if !is_text then
                       begin
                         Lwt.return @@ Eliom_content.Html.F.table [
                           Eliom_content.Html.F.tr [
                             Eliom_content.Html.F.td[
                               Eliom_content.Html.F.pcdata !uri
                             ]
                           ]
                         ]
                       end

                     else
                       begin
                         Lwt.return @@ Eliom_content.Html.F.table [
                           Eliom_content.Html.F.tr [
                             Eliom_content.Html.F.td[Eliom_content.Html.D.img
                                                       ~a:[ Eliom_content.Html.F.a_style "width:100px; height:100px;" ]
                                                       ~alt:"Ocsigen"
                                                       ~src: (Eliom_content.Xml.uri_of_string !uri) ()]]
                         ]
                       end


                  )
              in
              Lwt.return ()))
       : unit)
    ];




  Lwt.return Eliom_content.Html.[
    F.h1 [%i18n essai_intent_button]
  ;F.p [F.pcdata [%i18n S.only_works_on_smartphone]]
  ;F.p [%i18n essai_intent_explanation2]
  ;F.p [button]
  ]
