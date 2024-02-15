/// <summary>
/// PageExtension WSC Customer List (ID 81001) extends Record Customer List.
/// </summary>
pageextension 81001 "WSC Customer List" extends "Customer List"
{
    layout
    {
        addfirst(content)
        {
            usercontrol(SlideImages; "WSC Slide Images Control")
            {
                ApplicationArea = All;
                trigger OnStartup()
                begin
                    if not SlideLoaded then
                        UploadAllImages();
                end;
            }
        }
    }

    local procedure UploadAllImages()
    var
        JObject: JsonObject;
        Slides: JsonArray;
    begin
        SlideLoaded := true;
        Slides.Add(AddSlide('Keep your promises', 'check before you make a promise', '//unsplash.it/1024/200'));
        Slides.Add(AddSlide('Never forget', 'always register your conversations to ensure you follow-up promptly', '//unsplash.it/1025/200'));
        Slides.Add(AddSlide('Qualify', 'be picky about which opportunities to spend time on', '//unsplash.it/1024/201'));
        JObject.Add('slides', Slides);
        //To be reactivated
        //CurrPage.SlideImages.SetCarouselData(JObject);
    end;

    local procedure AddSlide(Title: Text; Description: Text; Image: Text): JsonObject
    var
        Slide: JsonObject;
    begin
        Slide.Add('title', Title);
        Slide.Add('description', Description);
        Slide.Add('image', Image);
        exit(Slide);
    end;

    var
        SlideLoaded: Boolean;
}