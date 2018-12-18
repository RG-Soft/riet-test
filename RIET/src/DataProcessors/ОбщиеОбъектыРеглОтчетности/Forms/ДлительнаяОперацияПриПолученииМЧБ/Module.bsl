&НаКлиенте
Перем ПараметрыОбработчикаОжидания;

&НаКлиенте
Перем ПолученОтветПользователя;

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ИмяФайлаОтчета = Параметры.ИмяФайлаОтчета;
	
	Если НЕ ЗначениеЗаполнено(ИмяФайлаОтчета) Тогда
		
		ИмяФайлаОтчета = "" + Новый УникальныйИдентификатор() + ".pdf";
		
	КонецЕсли;
	
	ПараметрыВызоваЭкспортнойПроцедуры = Параметры.ПараметрыВызоваЭкспортнойПроцедуры;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПолученОтветПользователя = Ложь;
	
	ДлительныеОперацииКлиент.ИнициализироватьПараметрыОбработчикаОжидания(ПараметрыОбработчикаОжидания);
	ПараметрыОбработчикаОжидания.МинимальныйИнтервал  = 5;  // минимальный интервал для проверок - 5 сек.
	ПараметрыОбработчикаОжидания.МаксимальныйИнтервал = 10; // максимальный интервал для проверок - 10 сек.
	
	РасчетноеВремяПолученияОчета = ТекущаяДата() + ПараметрыВызоваЭкспортнойПроцедуры.ВремяОжиданияДоПолученияОтчета;
	Элементы.ДекорацияПоясняющийТекстДлительнойОперации.Заголовок = "Пожалуйста подождите до "
		+ Формат(РасчетноеВремяПолученияОчета, "ДЛФ=T") + "...";
	
	ПодключитьОбработчикОжидания("Подключаемый_ПроверитьГотовностьОтчетаНаВебСервисе", ПараметрыОбработчикаОжидания.МинимальныйИнтервал, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПроверитьГотовностьОтчетаНаВебСервисе()
	
	Попытка
		
		Если ПроверитьГотовностьОтчетаНаВебСервисе() Тогда
			
			Закрыть();
			
			ВывестиМашиночитаемуюФорму();
			
			Возврат;
			
		КонецЕсли;
		
	Исключение
		
		Закрыть();
		
		ВызватьИсключение;
		
	КонецПопытки;
	
	ДлительныеОперацииКлиент.ОбновитьПараметрыОбработчикаОжидания(ПараметрыОбработчикаОжидания);
	
	Если НЕ ПолученОтветПользователя И (ПараметрыОбработчикаОжидания.ТекущийИнтервал = ПараметрыОбработчикаОжидания.МаксимальныйИнтервал И РасчетноеВремяПолученияОчета < ТекущаяДата()) Тогда
	
		СогласиеПользователяНаПродлениеОжиданияИлиЗакрытие(ПараметрыОбработчикаОжидания);
		Возврат;
		
	КонецЕсли;
	
	ПодключитьОбработчикОжидания("Подключаемый_ПроверитьГотовностьОтчетаНаВебСервисе", ПараметрыОбработчикаОжидания.ТекущийИнтервал, Истина);
	
КонецПроцедуры

&НаСервере
Функция ПроверитьГотовностьОтчетаНаВебСервисе()
	
	Если РегламентированнаяОтчетностьВызовСервера.ПолучитьМашиночитаемуюФормуСВебСервиса(ПараметрыВызоваЭкспортнойПроцедуры) Тогда
		
		Если ЗначениеЗаполнено(ПараметрыВызоваЭкспортнойПроцедуры.АдресОтчетаВоВременномХранилище) Тогда
			
			Возврат Истина;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

&НаКлиенте
Процедура ВывестиМашиночитаемуюФорму()

	АдресОтчетаВоВременномХранилище = ПараметрыВызоваЭкспортнойПроцедуры.АдресОтчетаВоВременномХранилище;
	
	#Если ВебКлиент Тогда
		
		ПолучитьФайл(АдресОтчетаВоВременномХранилище, ИмяФайлаОтчета, Истина);
		
	#Иначе
		
		ПолноеИмяФайлаОтчета = КаталогВременныхФайлов() + ИмяФайлаОтчета;
		
		ПередаваемыйФайл = Новый ОписаниеПередаваемогоФайла;
		ПередаваемыйФайл.Имя      = ПолноеИмяФайлаОтчета;
		ПередаваемыйФайл.Хранение = АдресОтчетаВоВременномХранилище;
		
		МассивПередаваемыхФайлов = Новый Массив;
		МассивПередаваемыхФайлов.Добавить(ПередаваемыйФайл);
		
		Если ПолучитьФайлы(МассивПередаваемыхФайлов, , , Ложь) Тогда
			ЗапуститьПриложение("""" + ПолноеИмяФайлаОтчета + """", , Истина);
			Попытка
				УдалитьФайлы(ПолноеИмяФайлаОтчета);
			Исключение
			КонецПопытки;
		КонецЕсли;
		
	#КонецЕсли

КонецПроцедуры

&НаКлиенте
Процедура СогласиеПользователяНаПродлениеОжиданияИлиЗакрытие(ПараметрыОбработчикаОжидания)
	
	ТекстВопроса = "Продолжить процесс получения машиночитаемой формы, сформированной веб-сервисом?";
	
	ОписаниеОповещения = Новый ОписаниеОповещения("СогласиеПользователяНаПродлениеОжиданияИлиЗакрытиеЗавершение", ЭтотОбъект, ПараметрыОбработчикаОжидания);
	ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, РежимДиалогаВопрос.ДаНет, 60, КодВозвратаДиалога.Нет, , КодВозвратаДиалога.Нет);
		
КонецПроцедуры

&НаКлиенте
Процедура СогласиеПользователяНаПродлениеОжиданияИлиЗакрытиеЗавершение(Ответ, ПараметрыОбработчикаОжидания) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		
		Закрыть();
		
	Иначе
		
		ПолученОтветПользователя = Истина;
		ПодключитьОбработчикОжидания("Подключаемый_ПроверитьГотовностьОтчетаНаВебСервисе", ПараметрыОбработчикаОжидания.ТекущийИнтервал, Истина);
			
	КонецЕсли;	
	
КонецПроцедуры

#КонецОбласти
