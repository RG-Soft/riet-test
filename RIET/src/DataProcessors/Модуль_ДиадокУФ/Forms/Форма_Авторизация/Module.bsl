
#Область ПЕРМЕННЫЕ_ПЛАТФОРМЫ

&НаКлиенте
Перем Платформа Экспорт;

&НаСервере
Перем ОбработкаОбъект;

#КонецОбласти

#Область ПРОЦЕДУРЫ_И_ФУНКЦИИ_ПЛАТФОРМЫ

&НаКлиенте
Функция МетодКлиента(ИмяМодуля= "", ИмяМетода, 
		Параметр0= NULL, Параметр1= NULL, Параметр2= NULL, Параметр3= NULL, Параметр4= NULL,
		Параметр5= NULL, Параметр6= NULL, Параметр7= NULL, Параметр8= NULL, Параметр9= NULL) Экспорт
	
	Возврат  Платформа.МетодКлиента(ИмяМодуля, ИмяМетода, 
	Параметр0, Параметр1, Параметр2, Параметр3, Параметр4,
	Параметр5, Параметр6, Параметр7, Параметр8, Параметр9);
	
КонецФункции

&НаКлиенте
Функция МетодСервераБезКонтекста(ИмяМодуля= "", ИмяМетода,
		Параметр0= NULL, Параметр1= NULL, Параметр2= NULL, Параметр3= NULL, Параметр4= NULL, 
		Параметр5= NULL, Параметр6= NULL, Параметр7= NULL, Параметр8= NULL, Параметр9= NULL) Экспорт
	
	Возврат Платформа.МетодСервераБезКонтекста(ИмяМодуля, ИмяМетода,
	Параметр0, Параметр1, Параметр2, Параметр3, Параметр4,
	Параметр5, Параметр6, Параметр7, Параметр8, Параметр9);
	
КонецФункции

&НаСервере
Функция МетодСервера(Знач ИмяМодуля= "", Знач ИмяМетода,
		Параметр0= NULL, Параметр1= NULL, Параметр2= NULL, Параметр3= NULL, Параметр4= NULL, 
		Параметр5= NULL, Параметр6= NULL, Параметр7= NULL, Параметр8= NULL, Параметр9= NULL) Экспорт
	
	Возврат ОбработкаОбъект().МетодСервера(ИмяМодуля, ИмяМетода, 
	Параметр0, Параметр1, Параметр2, Параметр3, Параметр4,
	Параметр5, Параметр6, Параметр7, Параметр8, Параметр9);
	
КонецФункции

&НаСервере
Функция ОбработкаОбъект() Экспорт
	
	Если ОбработкаОбъект = Неопределено Тогда
		ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	КонецЕсли;
	
	Возврат ОбработкаОбъект;
	
КонецФункции

&НаКлиенте
Функция ОсновнаяФорма(ТекущийВладелецФормы)
	
	Если ТекущийВладелецФормы = Неопределено Тогда
		Возврат Неопределено
	ИначеЕсли Прав(ТекущийВладелецФормы.ИмяФормы, 14) = "Форма_Основная" Тогда
		Возврат ТекущийВладелецФормы;
	Иначе
		Возврат ОсновнаяФорма(ТекущийВладелецФормы.ВладелецФормы);
	КонецЕсли;
	
КонецФункции


&НаСервере
Процедура ПлатформаПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("ОбъектПараметрыКлиентСервер", Объект.ПараметрыКлиентСервер);
	
КонецПроцедуры

&НаКлиенте
Процедура ПлатформаПриОткрытии(Отказ)
	
	ОсновнаяФорма= ОсновнаяФорма(ВладелецФормы);
	
	Если ОсновнаяФорма <> Неопределено Тогда
		Платформа= ОсновнаяФорма.Платформа;
	КонецЕсли;
		
	Платформа.ПриОткрытииФормыОбработки(ЭтаФорма, Отказ);
	
КонецПроцедуры

&НаКлиенте
Процедура ПлатформаПриЗакрытии()
	
	Платформа.ПриЗакрытииФормыОбработки(ЭтаФорма);
	
КонецПроцедуры

#КонецОбласти

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ПлатформаПриСозданииНаСервере(Отказ, СтандартнаяОбработка);
	
	Параметры.Свойство("Организация", Организация);
	
	Режим= Параметры.Режим;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПлатформаПриОткрытии(Отказ);

	ЭтаФорма.Заголовок = "Авторизация в " + Платформа.ПараметрыКлиент.СловарьWL.КраткоеНаименованиеСистемыПредложныйПадеж;
	
	Элементы.ТаблицаСертификатовИздатель.Видимость = Ложь;
	Элементы.ТаблицаСертификатовКонтур.Видимость = Ложь;
	Элементы.ТаблицаСертификатовВДиадоке.Видимость = Ложь;
	Элементы.ТаблицаСертификатовОшибка.Видимость = Ложь;
	Элементы.ТаблицаСертификатовОтпечатокСертификата.Видимость = Ложь;
	
	ЗаполнитьДанные();
	
	ОбновитьПредставлениеПоРежиму();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	
	ПлатформаПриЗакрытии();
	
КонецПроцедуры

&НаКлиенте
Процедура УправлениеВидимостью()
	
	Если Режим = "АвторизацияПоЛогину" Тогда
		Элементы.Комментарий.Видимость=	Ложь;
	Иначе
		Элементы.Комментарий.Видимость=	Истина;
	КонецЕсли;
	
КонецПроцедуры


&НаКлиенте
Процедура ВойтиВСистему(Команда)
	ВыбратьНажатие("");
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьНажатие(Элемент)
	
	DiadocConnectin = Неопределено;

	Интерпретация= "";
	
	ПредставлениеПользователя = "Неизвестный пользователь";
	Если Режим = "АвторизацияПоСертификату" Тогда
		
		ТекДанные = Элементы.ТаблицаСертификатов.ТекущиеДанные;
		
		Если ТекДанные = Неопределено ИЛИ НЕ ТекДанные.ВДиадоке  Тогда
			ПоказатьПредупреждение(, "Данный сертификат не имеет доступа в " + Платформа.ПараметрыКлиент.СловарьWL.НаименованиеСистемы + ", выберите другой действующий сертификат", 120, Платформа.ПараметрыКлиент.СловарьWL.НаименованиеСистемы);
			Возврат;
		КонецЕсли;
		
		текСертификат = ТекДанные.ОтпечатокСертификата;
		Попытка
			DiadocConnection = Платформа.ПараметрыКлиент.КонтекстРаботаССерверомДиадок.DiadocInvoiceAPI.CreateConnectionByCertificate(текСертификат);
			ПредставлениеПользователя = ТекДанные.Наименование;
		Исключение
			ПоказатьОшибкуПоСпецификатору(ОписаниеОшибки());
			ЭтаФорма.ТекущийЭлемент = Элементы.ТаблицаСертификатов;
		КонецПопытки;
		
	Иначе
		
		Логин=	СокрЛП(Логин);
		
		Если ПустаяСтрока(Логин) Тогда
			ПоказатьПредупреждение(, "Заполните логин", 120, Платформа.ПараметрыКлиент.СловарьWL.НаименованиеСистемы);
			ЭтаФорма.ТекущийЭлемент = Элементы.Логин;
			Возврат;
		КонецЕсли;
		
		Если ПустаяСтрока(Пароль) Тогда
			ПоказатьПредупреждение(, "Заполните пароль", 120, Платформа.ПараметрыКлиент.СловарьWL.НаименованиеСистемы);
			ЭтаФорма.ТекущийЭлемент = Элементы.Пароль;
			Возврат;
		КонецЕсли;
		
		текСертификат = "login:" + Логин;
		Попытка
			DiadocConnection = Платформа.ПараметрыКлиент.КонтекстРаботаССерверомДиадок.DiadocInvoiceAPI.CreateConnectionByLogin(Логин, Пароль);
			ПредставлениеПользователя = Логин;
		Исключение
			текстОшибки = ОписаниеОшибки();

			Спецификатор = ПоказатьОшибкуПоСпецификатору(текстОшибки);
			Если Спецификатор = "AuthorizationBadLogin" Тогда
				ЭтаФорма.ТекущийЭлемент = Элементы.Логин;
			ИначеЕсли Спецификатор = "AuthorizationBadPassword" Тогда
				ЭтаФорма.ТекущийЭлемент = Элементы.Пароль;
			КонецЕсли;
					
		КонецПопытки;
		
	КонецЕсли;
	
	Если DiadocConnection <> Неопределено Тогда
		
		Если ЗначениеЗаполнено(Организация) И НЕ МетодКлиента("Модуль_РаботаССерверомДиадок","ПроверитьДоступКОрганизации", DiadocConnection, Организация) Тогда
			ПоказатьПредупреждение(, "Под данной учетной записью в " + Платформа.ПараметрыКлиент.СловарьWL.КраткоеНаименованиеСистемыПредложныйПадеж + " нет доступа к организации """ + Организация + """", 120, Платформа.ПараметрыКлиент.СловарьWL.НаименованиеСистемы);
			Возврат;
		КонецЕсли;
		
		СтруктураНастроек = Новый Структура;
		СтруктураНастроек.Вставить("ДиадокПоследнийСертификатПользователя"	 , текСертификат);
		СтруктураНастроек.Вставить("ДиадокПоследнееПредставлениеПользователя", ПредставлениеПользователя);
		МетодСервераБезКонтекста(,"УстановитьНастройкиПользователей"		 , СтруктураНастроек);
		
		Закрыть(Новый Структура("DiadocConnection, ПредставлениеПользователя", DiadocConnection, ПредставлениеПользователя));
		
	КонецЕсли;
	
КонецПроцедуры


&НаКлиенте
Процедура ПереключениеРежимаВходаНажатие(Элемент, СтандартнаяОбработка)
	Режим = ? (Режим ="АвторизацияПоСертификату", "АвторизацияПоЛогину",  "АвторизацияПоСертификату");
	УправлениеВидимостью();
	ОбновитьПредставлениеПоРежиму();
	СтандартнаяОбработка = ложь;
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаСертификатовВыбор(Элемент, ВыбраннаяСтрока, Колонка, СтандартнаяОбработка)
	ВыбратьНажатие("");
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаСертификатовПриАктивизацииСтроки(Элемент)
	
	Если НЕ Элементы.ТаблицаСертификатов.ТекущиеДанные = Неопределено Тогда
		Если НЕ Элементы.ТаблицаСертификатов.ТекущиеДанные.ВДиадоке Тогда
			//Комментарий = Элементы.ТаблицаСертификатов.ТекущиеДанные.Ошибка;
			//ЗаписатьЗначениеРеквизитаФормы(Элементы.ТаблицаСертификатов.ТекущиеДанные.Ошибка,"Комментарий");
			Комментарий =Элементы.ТаблицаСертификатов.ТекущиеДанные.Ошибка;
		Иначе
			Комментарий = "";
			//ЗаписатьЗначениеРеквизитаФормы(Элементы.ТаблицаСертификатов.ТекущиеДанные.Ошибка,"");
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаСертификатовПередУдалением(Элемент, Отказ)
	Отказ = истина;
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаСертификатовПередНачаломИзменения(Элемент, Отказ)
	Отказ = истина;
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаСертификатовПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	Отказ=	Истина;
КонецПроцедуры


&НаКлиенте
Функция ПоказатьОшибкуПоСпецификатору(текстОшибки)
	
	СтруктураОшибки= МетодСервераБезКонтекста(,"ПолучитьСтруктуруОшибкиВнешнейКомпоненты", ТекстОшибки);
	
	Спецификатор= СтруктураОшибки.Спецификатор;
	
	Если Спецификатор = "InternetError" Тогда
		ОткрытьФормуВыводаОшибкиИнтернет();
	Иначе
		ОткрытьФормуВыводаОшибки(СтруктураОшибки);
	КонецЕсли;
	
	Возврат Спецификатор
	
КонецФункции

&НаКлиенте
Процедура ЗаполнитьДанные()

	Попытка
		
		Состояние("Получение списка сертификатов");
		
		Certificates = Платформа.ПараметрыКлиент.КонтекстРаботаССерверомДиадок.DiadocInvoiceAPI.GetPersonalCertificates();
		Для Индекс = 0 По Certificates.Count - 1 Цикл
			
			PersonalCertificate=	Certificates.GetItem(Индекс);
			
			стр = ТаблицаСертификатов.Добавить();
			
			Стр.Наименование = PersonalCertificate.Name;
			Стр.ДатаВыдачи = PersonalCertificate.BeginDate;
			Стр.СрокДействия = PersonalCertificate.EndDate;
			Стр.ОтпечатокСертификата = PersonalCertificate.Thumbprint;
			Стр.Организация = PersonalCertificate.OrganizationName;
			Стр.Издатель = PersonalCertificate.IssuerName;
			Стр.Контур = PersonalCertificate.IsKontur;
			попытка
				Стр.ИНН=	PersonalCertificate.INN;
				Стр.КПП=	PersonalCertificate.Kpp;
			Исключение КонецПопытки;	
			
			Если Стр.СрокДействия < НачалоДня(ТекущаяДата()) Тогда
				Стр.Ошибка = "Срок действия сертификата истек";
				Стр.ВДиадоке = Ложь;
			Иначе
				Стр.ВДиадоке = Истина;
			КонецЕсли;
		КонецЦикла;
		
	Исключение
		
		Результат=	Новый Структура();
		Результат.Вставить("ОписаниеОшибки", 	"Ошибка работы внешней компоненты");
		Результат.Вставить("Подробности", 		ОписаниеОшибки());
		
		ОткрытьФормуВыводаОшибки(Результат);
		Возврат;
		
	КонецПопытки;
	
	Попытка
		Для каждого стр Из ТаблицаСертификатов Цикл
			Если Стр.ВДиадоке Тогда
				Если НЕ Платформа.ПараметрыКлиент.КонтекстРаботаССерверомДиадок.DiadocInvoiceAPI.VerifyThatUserHasAccessToAnyBox(стр.ОтпечатокСертификата) Тогда
					Стр.Ошибка = "По сертификату нет доступа в " + Платформа.ПараметрыКлиент.СловарьWL.НаименованиеСистемы;
					Стр.ВДиадоке = Ложь;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	Исключение
		ПоказатьОшибкуПоСпецификатору(ОписаниеОшибки());
	КонецПопытки;
	
	ТаблицаСертификатов.Сортировать("ВДиадоке Убыв, Наименование Возр, ДатаВыдачи Убыв");
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьПредставлениеПоРежиму()
	
	Если ПолучитьЗначениеРеквизитаФормы("Режим") = "АвторизацияПоСертификату" Тогда
		Элементы.РежимыАвторизации.ТекущаяСтраница = Элементы.СтраницаВходПоСертификату;
		ЗаписатьЗначениеРеквизитаФормы("Войти по логину и паролю", "ПереключениеРежимаВхода");
	Иначе
		Элементы.РежимыАвторизации.ТекущаяСтраница = Элементы.СтраницаВходПоЛогину;
		ЗаписатьЗначениеРеквизитаФормы("Войти по сертификату", "ПереключениеРежимаВхода");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФормуВыводаОшибкиИнтернет()
	
	МетодКлиента(,"ОткрытьФормуОбработкиМодально", "Форма_ВыводОшибкиИнтернет",,ЭтаФорма, "ОбработчикВыводОшибкиИнтернет");
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФормуВыводаОшибки(Результат)
	
	ПараметрыФормы=	Новый Структура();
	ПараметрыФормы.Вставить("Заголовок", 		"Ошибка работы с модулем " + Платформа.ПараметрыКлиент.СловарьWL.НаименованиеСистемы);
	ПараметрыФормы.Вставить("ОписаниеОшибки", 	Результат.ОписаниеОшибки);
	ПараметрыФормы.Вставить("Подробности", 		Результат.Подробности);
	
	МетодКлиента(,"ОткрытьФормуОбработкиМодально", "Форма_ВыводОшибки", ПараметрыФормы, ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработчикВыводОшибкиИнтернет(РезультатВыбора, ДополнительныеПараметры) Экспорт
	Закрыть();
КонецПроцедуры

&НаСервере
Функция ПолучитьЗначениеРеквизитаФормы(ИмяРеквизита)
	мас = Новый Массив;
	мас.Добавить(Тип("ТаблицаЗначений"));
	мас.Добавить(Тип("ДеревоЗначений"));
		
	ТипРеквизита =ТипЗнч(ЭтаФорма[ИмяРеквизита]); 
	Если (Мас.Найти(ТипРеквизита) <> Неопределено) Или (Найти(ВРЕГ(ТипРеквизита), "ОБЪЕКТ") <> 0) тогда
		Возврат РеквизитФормыВЗначение(ИмяРеквизита);
	Иначе
		Возврат ЭтаФорма[ИмяРеквизита];
	конецесли;
КонецФункции

&НаСервере
Функция ЗаписатьЗначениеРеквизитаФормы(Значение,ИмяРеквизита)

	мас = Новый Массив;
	мас.Добавить(Тип("ТаблицаЗначений"));
	мас.Добавить(Тип("ДеревоЗначений"));
	
	
	ТипРеквизита =ТипЗнч(ЭтаФорма[ИмяРеквизита]); 
	Если (Мас.Найти(ТипРеквизита) <> Неопределено) Или (Найти(ВРЕГ(ТипРеквизита), "ОБЪЕКТ") <> 0) тогда
		ЗначениеВРеквизитФормы(Значение,ИмяРеквизита);
	Иначе
		ЭтаФорма[ИмяРеквизита] = Значение;
		
	конецесли;
	
	Возврат Истина;
КонецФункции
