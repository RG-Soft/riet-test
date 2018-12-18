////////////////////////////////////////////////////////////////////////////////
// Подсистема "Электронная подпись".
// 
////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Вызывается в форме добавления заявления на новый сертификат для заполнения реквизитов организации и при ее выборе.
//
// Параметры:
//  Параметры - Структура - со свойствами:
//
//    * Организация - СправочникСсылка.Организации - организация, которую нужно заполнить.
//                    Если организация уже заполнена, требуется перезаполнить ее свойства, например,
//                    при повтором вызове, когда пользователь выбрал другую организацию.
//                  - Неопределено, если подсистема "СтандартныеПодсистемы.Организации" не встроена.
//                    Пользователю недоступен выбор организации.
//
//    * ЭтоИндивидуальныйПредприниматель - Булево - (возвращаемое значение):
//                    Ложь   - начальное значение - указанная организация является юридическим лицом,
//                    Истина - указанная организация является индивидуальным предпринимателем.
//
//    * НаименованиеСокращенное  - Строка - (возвращаемое значение) краткое наименование организации.
//    * НаименованиеПолное       - Строка - (возвращаемое значение) краткое наименование организации.
//    * ИНН                      - Строка - (возвращаемое значение) ИНН организации.
//    * КПП                      - Строка - (возвращаемое значение) КПП организации.
//    * ОГРН                     - Строка - (возвращаемое значение) ОГРН организации.
//    * РасчетныйСчет            - Строка - (возвращаемое значение) основной расчетный счет организации для договора.
//    * БИК                      - Строка - (возвращаемое значение) БИК банка расчетного счета.
//    * КорреспондентскийСчет    - Строка - (возвращаемое значение) корреспондентский счет банка расчетного счета.
//    * Телефон                  - Строка - (возвращаемое значение) телефон организации в формате XML, как его
//                                 возвращает функция КонтактнаяИнформацияВXML общего модуля
//                                 УправлениеКонтактнойИнформацией.
//
//    * ЮридическийАдрес - Строка - (возвращаемое значение) юридический адрес организации в формате XML, как его
//                         возвращает функция КонтактнаяИнформацияВXML общего модуля УправлениеКонтактнойИнформацией.
//
//    * ФактическийАдрес - Строка - (возвращаемое значение) фактический адрес организации в формате XML, как его
//                         возвращает функция КонтактнаяИнформацияВXML общего модуля УправлениеКонтактнойИнформацией.
//
// Если реквизит (возвращаемое значение) остается равным начальному значению Неопределено,
// тогда он пропускается, если для значения Неопределено не указано другое поведение.
//
Процедура ПриЗаполненииРеквизитовОрганизацииВЗаявленииНаСертификат(Параметры) Экспорт
	
	
	
КонецПроцедуры

// Вызывается в форме добавления заявления на новый сертификат для заполнении реквизитов владельца и при его выборе.
//
// Параметры:
//  Параметры - Структура - со свойствами:
//    * Организация  - СправочникСсылка.Организации - выбранная организация, на которую оформляется сертификат.
//                   - Неопределено, если подсистема "СтандартныеПодсистемы.Организации" не встроена.
//
//    * ТипВладельца  - ОписаниеТипов - (возвращаемое значение) содержит ссылочные типы из которых можно сделать выбор.
//                    - Неопределено  - (возвращаемое значение) выбор владельца не поддерживается.
//
//    * Сотрудник    - ТипВладельца - (возвращаемое значение) - это владелец сертификата, которого нужно заполнить.
//                     Если уже заполнен (выбран пользователем), его не следует изменять.
//                   - Неопределено - если ТипВладельца не определен, тогда реквизит не доступен пользователю.
//
//    * Директор     - ТипВладельца - (возвращаемое значение) - это директор, который может быть выбран,
//                     как владелец сертификата.
//                   - Неопределено - начальное значение - скрыть директора из списка выбора.
//
//    * ГлавныйБухгалтер - ТипВладельца - (возвращаемое значение) это главный бухгалтер, который может быть выбран,
//                     как владелец сертификата.
//                   - Неопределено - начальное значение - скрыть главного бухгалтера из списка выбора.
//
//    * Пользователь - СправочникСсылка.Пользователи - (возвращаемое значение) пользователь-владелец сертификата.
//                     В общем случае, может быть не заполнено. Рекомендуется заполнить, если есть возможность.
//                     Записывается в сертификат в поле Пользователь, может быть изменено в дальнейшем.
//
//    * Фамилия            - Строка - (возвращаемое значение) фамилия сотрудника.
//    * Имя                - Строка - (возвращаемое значение) имя сотрудника.
//    * Отчество           - Строка - (возвращаемое значение) отчество сотрудника.
//    * ДатаРождения       - Дата   - (возвращаемое значение) дата рождения сотрудника.
//    * Пол                - Строка - (возвращаемое значение) пол сотрудника "Мужской" или "Женский".
//    * МестоРождения      - Строка - (возвращаемое значение) описание места рождения сотрудника.
//    * Гражданство        - СправочникСсылка.СтраныМира
//                                  - (возвращаемое значение) гражданство сотрудника.
//    * СтраховойНомерПФР  - Строка - (возвращаемое значение) СНИЛС сотрудника.
//    * Должность          - Строка - (возвращаемое значение) должность сотрудника в организации.
//
//    * Подразделение      - Строка - (возвращаемое значение) обособленное подразделение организации,
//                           в котором работает сотрудник.
//
//    * ДокументВид        - Строка - (возвращаемое значение) строки "21" или "91". 21 - паспорт гражданина РФ,
//                           91 - иной документ предусмотренный законодательством РФ (по СПДУЛ).
//
//    * ДокументНомер      - Строка - (возвращаемое значение) номер документа сотрудника (серия и
//                           номер для паспорта гражданина РФ).
//
//    * ДокументКемВыдан   - Строка - (возвращаемое значение) кем выдан документ сотрудника.
//    * ДокументДатаВыдачи - Дата   - (возвращаемое значение) дата выдачи документа сотрудника.
//
//    * ЭлектроннаяПочта   - Строка - (возвращаемое значение) адрес электронной почты сотрудника в формате XML, как его
//                           возвращает функция КонтактнаяИнформацияВXML общего модуля УправлениеКонтактнойИнформацией.
//
// Если реквизит (возвращаемое значение) остается равным начальному значению Неопределено,
// тогда он пропускается, если для значения Неопределено не указано другое поведение.
//
Процедура ПриЗаполненииРеквизитовВладельцаВЗаявленииНаСертификат(Параметры) Экспорт
	
	
	
КонецПроцедуры

// Вызывается в форме добавления заявления на новый сертификат для заполнения реквизитов руководителя и при его выборе.
// Только для юридического лица. Для индивидуального предпринимателя не требуется.
//
// Параметры:
//  Параметры - Структура - со свойствами:
//    * Организация   - СправочникСсылка.Организации - выбранная организация, на которую оформляется сертификат.
//                    - Неопределено, если подсистема "СтандартныеПодсистемы.Организации" не встроена.
//
//    * ТипРуководителя - ОписаниеТипов - (возвращаемое значение) содержит ссылочные типы из которых можно сделать
//                                        выбор.
//                      - Неопределено  - (возвращаемое значение) выбор партнера не поддерживается.
//
//    * Руководитель  - ТипРуководителя - это значение, выбранное пользователем по которому нужно заполнить должность.
//                    - Неопределено - ТипРуководителя не определен.
//                    - ЛюбаяСсылка - (возвращаемое значение) - руководитель, который будет подписывать документы.
//
//    * Представление - Строка - (возвращаемое значение) представление руководителя.
//                    - Неопределено - получить представление от значения Руководитель.
//
//    * Должность     - Строка - (возвращаемое значение) - должность руководителя, который будет подписывать документы.
//    * Основание     - Строка - (возвращаемое значение) - основание на котором действует должностное лицо (устав,
//                               доверенность, ...).
//
// Если реквизит (возвращаемое значение) остается равным начальному значению Неопределено,
// тогда он пропускается, если для значения Неопределено не указано другое поведение.
//
Процедура ПриЗаполненииРеквизитовРуководителяВЗаявленииНаСертификат(Параметры) Экспорт
	
	
	
КонецПроцедуры

// Вызывается в форме добавления заявления на новый сертификат для заполнения реквизитов партнера и при его выборе.
//
// Параметры:
//  Параметры - Структура - со свойствами:
//    * Организация   - СправочникСсылка.Организации - выбранная организация, на которую оформляется сертификат.
//                    - Неопределено, если подсистема "СтандартныеПодсистемы.Организации" не встроена.
//
//    * ТипПартнера   - ОписаниеТипов - содержит ссылочные типы из которых можно сделать выбор.
//                    - Неопределено - выбор партнера не поддерживается.
//
//    * Партнер       - ТипПартнера - это контрагент (обслуживающая организация), выбранный пользователем,
//                      по которому нужно заполнить реквизиты, описанные ниже.
//                    - Неопределено - ТипПартнера не определен.
//                    - ЛюбаяСсылка - (возвращаемое значение) - значение сохраняемое в заявке для истории.
//
//    * Представление - Строка - (возвращаемое значение) представление партнера.
//                    - Неопределено - получить представление от значения Партнер.
//
//    * ЭтоИндивидуальныйПредприниматель - Булево - (возвращаемое значение):
//                      Ложь   - начальное значение - указанный партнер является юридическим лицом,
//                      Истина - указанный партнер является индивидуальным предпринимателем.
//
//    * ИНН           - Строка - (возвращаемое значение) ИНН партнера.
//    * КПП           - Строка - (возвращаемое значение) КПП партнера.
//
// Если реквизит (возвращаемое значение) остается равным начальному значению Неопределено,
// тогда он пропускается, если для значения Неопределено не указано другое поведение.
//
Процедура ПриЗаполненииРеквизитовПартнераВЗаявленииНаСертификат(Параметры) Экспорт
	
	
	
КонецПроцедуры


// Вызывается в форме элемента справочника СертификатыКлючейЭлектроннойПодписиИШифрования и в других местах,
// где создаются или обновляются сертификаты, например в форме ВыборСертификатаДляПодписанияИлиРасшифровки.
// Допускается вызов исключения, если требуется остановить действие и что-то сообщить пользователю,
// например, при попытке создать элемент-копию сертификата, доступ к которому ограничен.
//
// Параметры:
//  Ссылка     - СправочникСсылка.СертификатыКлючейЭлектроннойПодписиИШифрования - пустая для нового элемента.
//
//  Сертификат - СертификатКриптографии - сертификат для которого создается или обновляется элемент справочника.
//
//  ПараметрыРеквизитов - ТаблицаЗначений - с колонками:
//               * ИмяРеквизита       - Строка - имя реквизита для которого можно уточнить параметры.
//               * ТолькоПросмотр     - Булево - если установить Истина, редактирование будет запрещено.
//               * ПроверкаЗаполнения - Булево - если установить Истина, заполнение будет проверяться.
//               * Видимость          - Булево - если установить Истина, реквизит станет невидимым.
//               * ЗначениеЗаполнения - Произвольный - начальное значение реквизита нового объекта.
//                                    - Неопределено - заполнение не требуется.
//
Процедура ПередНачаломРедактированияСертификатаКлюча(Ссылка, Сертификат, ПараметрыРеквизитов) Экспорт
	
	
	
КонецПроцедуры

// Вызывается при создании на сервере форм ПодписаниеДанных, РасшифровкаДанных.
// Используется для дополнительных действий, которые требуют серверного вызова, чтобы не
// вызывать сервер лишний раз.
//
// Параметры:
//  Операция          - Строка - строка Подписание или Расшифровка.
//
//  ВходныеПараметры  - Произвольный - значение свойства ПараметрыДополнительныхДействий
//                      параметра ОписаниеДанных методов Подписать, Расшифровать общего
//                      модуля ЭлектроннаяПодписьКлиент.
//                      
//  ВыходныеПараметры - Произвольный - произвольные возвращаемые данные, которые
//                      будут помещены в одноименную процедуру в общем модуле.
//                      ЭлектроннаяПодписьКлиентПереопределяемый после создания формы
//                      на сервере, но до ее открытия.
//
Процедура ПередНачаломОперации(Операция, ВходныеПараметры, ВыходныеПараметры) Экспорт
	
	
	
КонецПроцедуры

// Вызывается для расширения состава выполняемых проверок.
//
// Параметры:
//  Сертификат - СправочникСсылка.СертификатыКлючейЭлектроннойПодписиИШифрования - проверяемый сертификат.
// 
//  ДополнительныеПроверки - ТаблицаЗначений - с полями:
//    * Имя           - Строка - имя дополнительной проверки, например, АвторизацияВТакском.
//    * Представление - Строка - пользовательское имя проверки, например, "Авторизация на сервере Такском".
//    * Подсказка     - Строка - подсказка, которая будет показана пользователю при нажатии на знак вопроса.
//
//  ПараметрыДополнительныхПроверок - Произвольный - значение одноименного параметра, указанное
//    в процедуре ПроверитьСертификатСправочника общего модуля ЭлектроннаяПодписьКлиент.
//
//  СтандартныеПроверки - Булево - если установить Ложь, тогда все стандартные проверки будут
//    пропущены и скрыты. Скрытые проверки не попадают в свойство Результат
//    процедуры ПроверитьСертификатСправочника общего модуля ЭлектроннаяПодписьКлиент, кроме того
//    параметр МенеджерКриптографии не будет определен в процедурах ПриДополнительнойПроверкеСертификата
//    общих модулей ЭлектроннаяПодписьПереопределяемый и ЭлектроннаяПодписьКлиентПереопределяемый.
//
Процедура ПриСозданииФормыПроверкаСертификата(Сертификат, ДополнительныеПроверки, ПараметрыДополнительныхПроверок, СтандартныеПроверки) Экспорт
	
	//{ RG-Soft
	ПроверитьАвторизацию = Неопределено;
	Если ТипЗнч(ПараметрыДополнительныхПроверок) = Тип("Структура")
		И ПараметрыДополнительныхПроверок.Свойство("ПроверитьАвторизацию", ПроверитьАвторизацию)
		И ПроверитьАвторизацию = Истина Тогда
		
		НоваяПроверка = ДополнительныеПроверки.Добавить();
		НоваяПроверка.Имя = "ТестСвязиСОператором";
		НоваяПроверка.Представление = ВернутьСтр("ru = 'Аутентификация на сервере оператора ЭДО'");
		Подсказка = ВернутьСтр("ru = 'Проверяет возможность аутентификации на сервере оператора электронного документооборота.
			|Требуется пароль.'");
		НоваяПроверка.Подсказка = Подсказка;
	КонецЕсли;	//} RG-Soft
	
КонецПроцедуры

// Вызывается из формы ПроверкаСертификата, если при создании формы были добавлены дополнительные проверки.
//
// Параметры:
//  Сертификат           - СправочникСсылка.СертификатыКлючейЭлектроннойПодписиИШифрования - проверяемый сертификат.
//  Проверка             - Строка - имя проверки, добавленное в процедуре ПриСозданииФормыПроверкаСертификата
//                            общего модуля ЭлектроннаяПодписьПереопределяемый.
//  МенеджерКриптографии - МенеджерКриптографии - подготовленный менеджер криптографии для
//                            выполнения проверки.
//                       - Неопределено - если стандартные проверки отключены в процедуре
//                            ПриСозданииФормыПроверкаСертификата общего модуля ЭлектроннаяПодписьПереопределяемый.
//  ОписаниеОшибки       - Строка - (возвращаемое значение) - описание ошибки, полученной при выполнении проверки.
//                            Это описание сможет увидеть пользователь при нажатии на картинку результата.
//  ЭтоПредупреждение    - Булево - (возвращаемое значение) - вид картинки Ошибка/Предупреждение 
//                            начальное значение Ложь.
// 
Процедура ПриДополнительнойПроверкеСертификата(Сертификат, Проверка, МенеджерКриптографии, ОписаниеОшибки, ЭтоПредупреждение) Экспорт
	
	//{ RG-Soft
	ЭлектронныеДокументыСлужебный.ПриДополнительнойПроверкеСертификата(
		Сертификат, Проверка, МенеджерКриптографии, ОписаниеОшибки, ЭтоПредупреждение); //} RG-Soft
		
КонецПроцедуры

#КонецОбласти
