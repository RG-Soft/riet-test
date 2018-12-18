
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	РасшифровкаИзОтчета = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "РасшифровкаИзОтчета");
	Если РасшифровкаИзОтчета <> Неопределено Тогда
		Отчет = Отчеты.АнализЖурналаРегистрации.РасшифровкаРегламентногоЗадания(РасшифровкаИзОтчета).Отчет;
		
		ИмяРегламентногоЗадания = РасшифровкаИзОтчета.Получить(1);
		НаименованиеСобытия = РасшифровкаИзОтчета.Получить(2);
		Заголовок = НаименованиеСобытия;
		Если ИмяРегламентногоЗадания <> "" Тогда
			НазваниеСобытия = СтрЗаменить(ИмяРегламентногоЗадания, "РегламентноеЗадание.", "");
			
			УстановитьПривилегированныйРежим(Истина);
			ОтборПоРегламентнымЗаданиям = Новый Структура;
			МетаданныеРегламентногоЗадания = Метаданные.РегламентныеЗадания.Найти(НазваниеСобытия);
			Если МетаданныеРегламентногоЗадания <> Неопределено Тогда
				ОтборПоРегламентнымЗаданиям.Вставить("Метаданные", МетаданныеРегламентногоЗадания);
				Если НаименованиеСобытия <> Неопределено Тогда
					ОтборПоРегламентнымЗаданиям.Вставить("Наименование", НаименованиеСобытия);
				КонецЕсли;
				РегЗадание = РегламентныеЗадания.ПолучитьРегламентныеЗадания(ОтборПоРегламентнымЗаданиям);
				Если ЗначениеЗаполнено(РегЗадание) Тогда
					ИдентификаторРегламентногоЗадания = РегЗадание[0].УникальныйИдентификатор;
				КонецЕсли;
			КонецЕсли;
			УстановитьПривилегированныйРежим(Ложь);
		КонецЕсли;
	Иначе
		Отчет = Параметры.Отчет;
		ИдентификаторРегламентногоЗадания = Параметры.ИдентификаторРегламентногоЗадания;
		Заголовок = Параметры.Заголовок;
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РегламентныеЗадания") Тогда
		ПодсистемаРегламентныеЗаданияСуществует = Истина;
		Элементы.ИзменитьРасписание.Видимость = Истина;
	Иначе
		Элементы.ИзменитьРасписание.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ОтчетОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ДатаНачала = Расшифровка.Получить(0);
	ДатаОкончания = Расшифровка.Получить(1);
	СеансРегламентногоЗадания.Очистить();
	СеансРегламентногоЗадания.Добавить(Расшифровка.Получить(2)); 
	ОтборЖурналаРегистрации = Новый Структура("Сеанс, ДатаНачала, ДатаОкончания", СеансРегламентногоЗадания, ДатаНачала, ДатаОкончания);
	ОткрытьФорму("Обработка.ЖурналРегистрации.Форма.ЖурналРегистрации", ОтборЖурналаРегистрации);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура НастроитьРасписаниеРегламентногоЗадания(Команда)
	
	Если ЗначениеЗаполнено(ИдентификаторРегламентногоЗадания) Тогда
		
		Диалог = Новый ДиалогРасписанияРегламентногоЗадания(ПолучитьРасписание());
		
		ОписаниеОповещения = Новый ОписаниеОповещения("НастроитьРасписаниеРегламентногоЗаданияЗавершение", ЭтотОбъект);
		Диалог.Показать(ОписаниеОповещения);
		
	Иначе
		ПоказатьПредупреждение(,ВернутьСтр("ru = 'Невозможно получить расписание регламентного задания: регламентное задание было удалено или не указано его наименование.'"));
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиКЖурналуРегистрации(Команда)
	
	Для Каждого Область Из Отчет.ВыделенныеОбласти Цикл
		Если Область.Имя = ТипОбластиЯчеекТабличногоДокумента.Прямоугольник Тогда
			Расшифровка = Область.Расшифровка;
		Иначе
			Расшифровка = Неопределено;
		КонецЕсли;
		Если Расшифровка = Неопределено
			ИЛИ Область.Верх <> Область.Низ Тогда
			ПоказатьПредупреждение(,ВернутьСтр("ru = 'Выберите строку или ячейку нужного сеанса задания'"));
			Возврат;
		КонецЕсли;
		ДатаНачала = Расшифровка.Получить(0);
		ДатаОкончания = Расшифровка.Получить(1);
		СеансРегламентногоЗадания.Очистить();
		СеансРегламентногоЗадания.Добавить(Расшифровка.Получить(2));
		ОтборЖурналаРегистрации = Новый Структура("Сеанс, ДатаНачала, ДатаОкончания", СеансРегламентногоЗадания, ДатаНачала, ДатаОкончания);
		ОткрытьФорму("Обработка.ЖурналРегистрации.Форма.ЖурналРегистрации", ОтборЖурналаРегистрации);
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ПолучитьРасписание()
	
	УстановитьПривилегированныйРежим(Истина);
	
	МодульРегламентныеЗаданияСервер = ОбщегоНазначения.ОбщийМодуль("РегламентныеЗаданияСервер");
	Возврат МодульРегламентныеЗаданияСервер.РасписаниеРегламентногоЗадания(ИдентификаторРегламентногоЗадания);
	
КонецФункции

&НаКлиенте
Процедура НастроитьРасписаниеРегламентногоЗаданияЗавершение(Расписание, ДополнительныеПараметры) Экспорт
	
	Если Расписание <> Неопределено Тогда
		УстановитьРасписаниеРегламентногоЗадания(Расписание);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьРасписаниеРегламентногоЗадания(Расписание)
	
	УстановитьПривилегированныйРежим(Истина);
	
	ПараметрыЗадания = Новый Структура;
	ПараметрыЗадания.Вставить("Расписание", Расписание);
	МодульРегламентныеЗаданияСервер = ОбщегоНазначения.ОбщийМодуль("РегламентныеЗаданияСервер");
	МодульРегламентныеЗаданияСервер.ИзменитьЗадание(ИдентификаторРегламентногоЗадания, ПараметрыЗадания);
	
КонецПроцедуры

#КонецОбласти
