
&НаКлиенте
Процедура PushReady(Команда)
	
	PushReadyНаСервере();
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура PushReadyНаСервере()
	
	Обработки.TCSPushCustomsFiles.PushCustomsFiles();
	
КонецПроцедуры

