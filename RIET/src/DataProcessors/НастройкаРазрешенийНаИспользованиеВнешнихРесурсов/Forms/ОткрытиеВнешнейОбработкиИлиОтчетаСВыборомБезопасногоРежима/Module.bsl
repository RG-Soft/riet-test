#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
	
	Если Не ЗначениеЗаполнено(ФайлОбработкиИмя) Или Не ЗначениеЗаполнено(ФайлОбработкиАдрес) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ВернутьСтр("ru = 'Укажите файл внешнего отчета или обработки'"), , "ФайлОбработкиАдрес");
		Отказ = Истина;
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(БезопасныйРежим) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ВернутьСтр("ru = 'Укажите безопасный режим для подключения внешнего модуля'"), , "БезопасныйРежим");
		Отказ = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовУправленияФормы

&НаКлиенте
Процедура ФайлОбработкиИмяНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Истина;
	
	Оповещение = Новый ОписаниеОповещения("ФайлОбработкиИмяНачалоВыбораПослеПомещенияФайла", ЭтотОбъект);
	НачатьПомещениеФайла(Оповещение, , , Истина, ЭтотОбъект.УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура ФайлОбработкиИмяНачалоВыбораПослеПомещенияФайла(Результат, Адрес, ВыбранноеИмяФайла, Контекст) Экспорт
	
	Если Результат Тогда
		
		ФайлОбработкиИмя = ВыбранноеИмяФайла;
		ФайлОбработкиАдрес = Адрес;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ФайлОбработкиИмяОчистка(Элемент, СтандартнаяОбработка)
	
	УдалитьИзВременногоХранилища(ФайлОбработкиАдрес);
	
	ФайлОбработкиАдрес = "";
	ФайлОбработкиИмя = "";
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПодключитьИОткрыть(Команда)
	
	Если ПроверитьЗаполнение() Тогда
		
		Имя = ПодключитьНаСервере();
		
		Расширение = Прав(НРег(СокрЛП(ФайлОбработкиИмя)), 3);
		
		Если Расширение = "epf" Тогда
			
			ИмяФормыВнешнегоМодуля = "ВнешняяОбработка." + Имя + ".Форма";
			
		Иначе
			
			ИмяФормыВнешнегоМодуля = "ВнешнийОтчет." + Имя + ".Форма";
			
		КонецЕсли;
		
		ОткрытьФорму(ИмяФормыВнешнегоМодуля, , ЭтотОбъект, , , , , РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ПодключитьНаСервере()
	
	Если Не Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		ВызватьИсключение ВернутьСтр("ru = 'Недостаточно прав доступа.'");
	КонецЕсли;
	
	Расширение = Прав(НРег(СокрЛП(ФайлОбработкиИмя)), 3);
	
	Если Расширение = "epf" Тогда
		
		Менеджер = ВнешниеОбработки;
		
	ИначеЕсли Расширение = "erf" Тогда
		
		Менеджер = ВнешниеОтчеты;
		
	Иначе
		
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ВернутьСтр("ru = 'Файл %1 не является файлом внешнего отчета или обработки'"), ФайлОбработкиИмя);
		
	КонецЕсли;
	
	Имя = Менеджер.Подключить(ФайлОбработкиАдрес, , БезопасныйРежим);
	
	Возврат Имя;
	
КонецФункции

#КонецОбласти
