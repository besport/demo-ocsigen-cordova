(* Contacts demo *)

[%%shared
  open Eliom_content.Html
  open Eliom_content.Html.F
]

(* Service for this demo, defined in the server-side app *)
let%server service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["essai_contacts"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

(* Make service available on the client *)
let%client service = ~%service

(* Name for demo menu. This value is defined both server and client-side. *)
let%shared name () = [%i18n S.essai_contacts]

(* Class for the page containing this demo (for internal use) *)
let%shared page_class = "os-page-essai-contacts"

(*Functions to verify you're on the mobile app or not*)
[%%client
  let has uA s = uA##indexOf(Js.string s) <> -1
  let is_android () =
    let uA = Dom_html.window##.navigator##.userAgent in
    (has uA "Android")

  let is_client_app () = Eliom_client.is_client_app ()
]

(*Contacts list*)
let%client myList = ref []
(* function that prints the whole contacts list *)
let%shared print_contacts () =
  let _ : unit Eliom_client_value.t =
    [%client
      let rec print_list l = match l with
        | [] -> ()
        | a::ll ->
          print_endline a;
          print_list ll
      in

      print_list !myList;
    ] in
  Lwt.return()



(* function that adds a new contact you pick in your contacts list in myList *)
let%shared add_contact () =

  let _ : unit Eliom_client_value.t =
    [%client
      if is_client_app () then
        begin
          let contact myContact=
            let head =
              match Cordova_contacts.Contact.phone_numbers myContact with
              | Some(x::_) -> x
              | _ -> raise (Failure "empty")
            in
            myList := (Cordova_contacts.ContactField.value head)::(!myList);
            Eliom_lib.alert "%s%!" (Cordova_contacts.ContactField.value head);
          in
          Cordova_contacts.Contacts.pick_contact contact;
        end else
        begin
          Eliom_lib.alert "You can't add a contact: you need to use the mobile application!"
        end
    ] in
  Lwt.return ()




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


  let btn1 =
    button [%i18n S.essai_contacts_click1]
      [%client
        ((fun () ->
           add_contact ();
           Lwt.return ())
         : unit -> unit Lwt.t)
      ]
  in

  let btn2 =
    button [%i18n S.essai_contacts_click2]
      [%client
        ((fun () ->
           print_contacts ();
           Lwt.return ())
         : unit -> unit Lwt.t)
      ]
  in

  Lwt.return Eliom_content.Html.[
    F.h1 [%i18n essai_contacts_button]
  ; F.p [F.pcdata [%i18n S.only_works_on_smartphone]]
  ; F.p [F.pcdata [%i18n S.essai_contacts_button_description1]]
  ; F.p [btn1]
  ; F.p [F.pcdata [%i18n S.essai_contacts_button_description2]]
  ; F.p [btn2]
  ]
