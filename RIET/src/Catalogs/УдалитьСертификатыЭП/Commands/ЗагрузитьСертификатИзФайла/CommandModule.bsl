
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("ИдентификаторИсточника", ПараметрыВыполненияКоманды.Источник.УникальныйИдентификатор); 

	Если ЭлектронныеДокументыСлужебныйВызовСервера.ВыполнятьКриптооперацииНаСервере() Тогда
		Если Не ЭлектронныеДокументыСлужебныйВызовСервера.ЕстьКриптосредстваНаСервере() Тогда
			Возврат;
		КонецЕсли;
	Иначе
		
		РасширениеПодключено = ПодключитьРасширениеРаботыСКриптографией();

		Если НЕ РасширениеПодключено Тогда
			
			ЭлектронныеДокументыСлужебныйКлиент.УстановитьРасширениеРаботыСКриптографиейНаКлиенте();
			Возврат;
			
		КонецЕсли;

	КонецЕсли;
	
	ЗагрузитьСертификатИзФайла(ДополнительныеПараметры);

	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьСертификатИзФайла(ДополнительныеПараметры)
	
	РасширениеПодключено = ПодключитьРасширениеРаботыСКриптографией();
	
	Если НЕ РасширениеПодключено Тогда
	
		ТекстСообщения = ВернутьСтр("ru = '""Расширение для работы с криптографией"" не подключено, операция прервана.'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		Возврат
	КонецЕсли;
	
	Попытка
		МенеджерКриптографии = ЭлектронныеДокументыСлужебныйКлиент.ПолучитьМенеджерКриптографии();
	Исключение
		ТекстСообщения = ЭлектронныеДокументыСлужебныйВызовСервера.ПолучитьСообщениеОбОшибке("100");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		Возврат;
	КонецПопытки;
	
	ИдентификаторИсточника = ДополнительныеПараметры.ИдентификаторИсточника;
	ОбработчикОповещения = Новый ОписаниеОповещения("ЗагрузитьСертификатОповещение", ЭтотОбъект, Неопределено);
	АдресВХранилище = Неопределено;
	
	НачатьПомещениеФайла(ОбработчикОповещения, АдресВХранилище,, Истина, ИдентификаторИсточника);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьСертификатОповещение(Результат, АдресВХранилище, ИмяФайла, ДополнительныеПараметры) Экспорт
	
	Если Не Результат Тогда
		Возврат;
	КонецЕсли;
	
	СтруктураСертификата = ПодготовитьФайлСертификатаНаСервере(АдресВХранилище);
	Если СтруктураСертификата = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Организация = Неопределено;
	
	ЭлектронныеДокументыСлужебныйВызовСервера.ОпределитьОрганизацию(Организация);
	
	Если НЕ ЗначениеЗаполнено(Организация) Тогда
				
		ДополнительныеПараметры = Новый Структура;
		ДополнительныеПараметры.Вставить("СтруктураСертификата", СтруктураСертификата);
		
		ОбработчикОповещения = Новый ОписаниеОповещения("ВыборОрганизацииОповещение", ЭтотОбъект, ДополнительныеПараметры);
		
		Режим = РежимОткрытияОкнаФормы.БлокироватьОкноВладельца;
		
		ОткрытьФорму("Справочник.УдалитьСертификатыЭП.Форма.ВыборОрганизации",,,,,,ОбработчикОповещения, Режим);

	КонецЕсли;

	ЗагрузитьСертификат(Организация, СтруктураСертификата);

	
КонецПроцедуры

&НаКлиенте
Процедура ВыборОрганизацииОповещение(Организация, ДополнительныеПараметры) Экспорт
	
	Если Организация = Неопределено Тогда
		 Возврат;
	КонецЕсли;
	
	СтруктураСертификата = ДополнительныеПараметры.СтруктураСертификата;
	
	ЗагрузитьСертификат(Организация, СтруктураСертификата);
	
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьСертификат(Организация, СтруктураСертификата)
	
	НазваниеСправочникаОрганизации = ИмяПрикладногоСправочника("Организации");
	Если Не ЗначениеЗаполнено(НазваниеСправочникаОрганизации) Тогда
		НазваниеСправочникаОрганизации = "Организации";
	КонецЕсли;
	
	Если ТипЗнч(Организация) = Тип("СправочникСсылка." + НазваниеСправочникаОрганизации) И ЗначениеЗаполнено(Организация) Тогда
		СтруктураСертификата.Вставить("Организация", Организация);
	Иначе
		Возврат;
	КонецЕсли;

	ТекстСообщения = "";
	СсылкаНаОбъект = ЭлектронныеДокументыСлужебныйВызовСервера.ЗагрузитьСертификат(СтруктураСертификата, ТекстСообщения);
	Если НЕ ЗначениеЗаполнено(СсылкаНаОбъект) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		Возврат;
	КонецЕсли;
	
	ПараметрыФормы = Новый Структура("Ключ", СсылкаНаОбъект);
	ОткрытьФорму("Справочник.УдалитьСертификатыЭП.Форма.ФормаЭлемента", ПараметрыФормы);
	ОповеститьОбИзменении(СсылкаНаОбъект);
	Оповестить("ОбновитьСписокСертификатов");
	
КонецПроцедуры


&НаСервере
Функция ПодготовитьФайлСертификатаНаСервере(Знач АдресВХранилище)
	
	УстановитьПривилегированныйРежим(Истина);
	ДанныеФайлаСертификата = ПолучитьИзВременногоХранилища(АдресВХранилище);
	
	Попытка
		НовыйСертификат = Новый СертификатКриптографии(ДанныеФайлаСертификата);
	Исключение
		ТекстСообщения = ВернутьСтр("ru = 'Файл сертификата должен быть в формате DER X.509, операция прервана.'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		Возврат Неопределено;
	КонецПопытки;
	
	СтруктураСертификата = ЭлектроннаяПодписьКлиентСервер.ЗаполнитьСтруктуруСертификата(НовыйСертификат);
	СтруктураСертификата.Вставить("ДвоичныеДанныеСертификата", ДанныеФайлаСертификата);
	
	Возврат СтруктураСертификата;
	
КонецФункции

 &НаСервере
Функция ИмяПрикладногоСправочника(Название)
	
	Возврат ЭлектронныеДокументыПовтИсп.ПолучитьИмяПрикладногоСправочника(Название);
	
КонецФункции


