﻿
#Область СтрокаНеобработанные

//&НаСервере
//Функция ПолучитьГруппуДереваПоИдентификатору(Идентификатор)
//	
//	ГруппаДерева = ДеревоНоменклатуры.НайтиПоИдентификатору(Идентификатор);
//	Если Не ГруппаДерева.ЭтоГруппа Тогда
//		ГруппаДерева = ГруппаДерева.ПолучитьРодителя();
//	КонецЕсли;
//	
//	Возврат ГруппаДерева;
//	
//КонецФункции

&НаСервере
Функция ПолучитьГруппуДереваДляНоменклатуры(Номенклатура)
	
	ИдентификаторСтроки = Элементы.ДеревоНоменклатуры.ТекущаяСтрока;
	
	Если ИдентификаторСтроки = Неопределено Тогда
		
		Если Номенклатура = Неопределено Тогда
			Возврат Неопределено;
		КонецЕсли;
		
		ГруппаНоменклатуры = Неопределено;
		Для Каждого Группа Из ГруппыНоменклатуры1Уровня Цикл
			Если Номенклатура.ПринадлежитЭлементу(Группа) Тогда
				ГруппаНоменклатуры = Группа;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Если ГруппаНоменклатуры = Неопределено Тогда
			Возврат Неопределено;
		КонецЕсли;
		
		ГруппаДерева = Неопределено;
		Для Каждого СтрокаДерева Из ДеревоНоменклатуры.ПолучитьЭлементы() Цикл
			Если СтрокаДерева.Номенклатура = ГруппаНоменклатуры Тогда
				ГруппаДерева = СтрокаДерева;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Если ГруппаДерева = Неопределено Тогда
			ГруппаДерева = ДеревоНоменклатуры.ПолучитьЭлементы().Добавить();
			ГруппаДерева.Номенклатура = ГруппаНоменклатуры;
			ГруппаДерева.ЭтоГруппа    = Истина;
		КонецЕсли;
		
		Возврат ГруппаДерева;
		
	КонецЕсли;
	
	//Возврат ПолучитьГруппуДереваПоИдентификатору(ИдентификаторСтроки);
	ГруппаДерева = ДеревоНоменклатуры.НайтиПоИдентификатору(ИдентификаторСтроки);
	Если Не ГруппаДерева.ЭтоГруппа Тогда
		ГруппаДерева = ГруппаДерева.ПолучитьРодителя();
	КонецЕсли;
	
	Возврат ГруппаДерева;
	
КонецФункции

&НаСервере
Процедура ПеренестиНоменклатуру(Номенклатура, Приемник=Неопределено)
	
	ГруппаДерева = ПолучитьГруппуДереваДляНоменклатуры(Номенклатура);
	
	Если ГруппаДерева = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ЭлементДерева = ГруппаДерева.ПолучитьЭлементы().Добавить();
	ЭлементДерева.Номенклатура = Номенклатура;
	
	НайденныеСтроки = Объект.СтрокиНеобработанные.НайтиСтроки(Новый Структура("Номенклатура, Выбрана", Номенклатура, Ложь));
	Для Каждого СтрокаОбработки Из НайденныеСтроки Цикл
		СтрокаОбработки.Группа  = ГруппаДерева.Номенклатура;
		СтрокаОбработки.Выбрана = Истина;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура СтрокиНеобработанныеВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ПеренестиНоменклатуру(Элемент.ТекущиеДанные.Номенклатура);
	
КонецПроцедуры

#КонецОбласти // СтрокаНеобработанные

#Область ФормированиеФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	Номенклатура.Ссылка КАК Группа
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура
	|ГДЕ
	|	Номенклатура.ЭтоГруппа
	|	И Номенклатура.Родитель = ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)"
	);
	
	ГруппыНоменклатуры1Уровня = Новый ФиксированныйМассив(Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Группа"));
	
	ЗаполнитьКонтрагентовДляОтправки();
	
	Объект.Менеджер = ПараметрыСеанса.ТекущийПользователь;
	
	ЗначенияРесурсов = Объект.Менеджер.КонтактнаяИнформация.Найти(Новый Структура("Вид", Справочники.ВидыКонтактнойИнформации.EmailПользователя));
	Если ЗначенияРесурсов <> Неопределено Тогда
		ПочтаПользователя = ЗначенияРесурсов.Представление;
	КонецЕсли;
	
	//-= временно
	Элементы.ФормаПеречень1.Доступность = Ложь;
	Элементы.ФормаПеречень2.Доступность = Ложь;
	Элементы.ФормаПеречень3.Доступность = Ложь;
	Элементы.ФормаПеречень3.Пометка = Истина;
	//-= до сих пор
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ПустаяСтрока(ПочтаПользователя) Тогда
		Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаСПочтовымиСообщениями") Тогда
			МодульРаботаСПочтовымиСообщениямиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("РаботаСПочтовымиСообщениямиКлиент");
			МодульРаботаСПочтовымиСообщениямиКлиент.СоздатьНовоеПисьмо();
		Иначе
			ФайловаяСистемаКлиент.ОткрытьНавигационнуюСсылку("mailto:" + ПочтаПользователя);
		КонецЕсли;
	КонецЕсли;
	
	ЗаполнитьТаблицы(ПолучитьОтбор());
	
	Элементы.СтрокиНеобработанные.ОтборСтрок = Новый ФиксированнаяСтруктура("Выбрана", Ложь);
	
	УстановитьОтборИНадпись(Неопределено);
	
КонецПроцедуры

#КонецОбласти // ФормированиеФормы

#Область ДополнительныеФункцииПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьТекстЗапросаНеобработанные() Экспорт
	
	Возврат
	"ВЫБРАТЬ
	|	ЗаявкаСтроки.ИдентификаторСтроки КАК ИдентификаторСтроки,
	|	ЗаявкаСтроки.Номенклатура КАК Номенклатура,
	|	ЗаявкаСтроки.Количество КАК Количество,
	|	ЗаявкаСтроки.ОсновноеСредство КАК ОсновноеСредство,
	|	ЗаявкаСтроки.Комментарий КАК Комментарий,
	|	ЗаявкаСтроки.Артикул КАК Артикул,
	|	ЗаявкаСтроки.ЕдиницаИзмерения КАК ЕдиницаИзмерения,
	|	ЗаявкаСтроки.Регистратор.Дата КАК РегистраторДата,
	|	ЗаявкаСтроки.АдресПоставки КАК АдресПоставки,
	|	ЗаявкаСтроки.СрокПоставки КАК СрокПоставки,
	|	ЗаявкаСтроки.Приоритет КАК Приоритет,
	|	ЗаявкаСтроки.Перечень КАК Перечень,
	|	ЗаявкаСтроки.НомерЗаявки КАК НомерЗаявки
	|ИЗ
	|	РегистрСведений.ЗаявкаСтроки КАК ЗаявкаСтроки
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗаявкаЦены КАК ЗаявкаЦены
	|		ПО ЗаявкаСтроки.ИдентификаторСтроки = ЗаявкаЦены.ИдентификаторСтроки
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗаявкаОтправленныеПоставщикам КАК ЗаявкаОтправленныеПоставщикам
	|		ПО ЗаявкаСтроки.ИдентификаторСтроки = ЗаявкаОтправленныеПоставщикам.ИдентификаторСтроки
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗаявкаТендер КАК ЗаявкаТендер
	|		ПО ЗаявкаСтроки.ИдентификаторСтроки = ЗаявкаТендер.ИдентификаторСтроки
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗаявкаОтмененные КАК ЗаявкаОтмененные
	|		ПО ЗаявкаСтроки.ИдентификаторСтроки = ЗаявкаОтмененные.ИдентификаторСтроки
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗаявкаМенеджеры КАК ЗаявкаМенеджеры
	|		ПО ЗаявкаСтроки.ИдентификаторСтроки = ЗаявкаМенеджеры.ИдентификаторСтроки
	|ГДЕ
	|	ЗаявкаСтроки.Перечень В(&ПеречниЗакупа)
	|	И ЗаявкаЦены.ИдентификаторСтроки ЕСТЬ NULL
	|	И ЗаявкаОтправленныеПоставщикам.ИдентификаторСтроки ЕСТЬ NULL
	|	И ЗаявкаТендер.ИдентификаторСтроки ЕСТЬ NULL
	|	И ЗаявкаОтмененные.ИдентификаторСтроки ЕСТЬ NULL
	|	И ЗаявкаМенеджеры.ИдентификаторСтроки ЕСТЬ NULL";
	//|	И (ЗаявкаСтроки.Менеджер = &Менеджер
	//|			ИЛИ &Менеджер = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка))";
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьТекстЗапросаОтправленные() Экспорт
	
	Возврат
	"ВЫБРАТЬ
	|	ЗаявкиОтправлено.ИдСтроки,
	|	ЗаявкиОтправлено.Контрагент,
	|	ЗаявкиОтправлено.ИДпустогоКонтрагента,
	|	ЗаявкиОтправлено.Менеджер,
	|	ЗаявкиОтправлено.ЛогОтправлено,
	|	ЗаявкиОтправлено.Емайл,
	|	ЗаявкиОтправлено.ДтОтправки,
	|	ЗаявкиОтправлено.Группа,
	|	ЗаявкиОтправлено.КомПоставщик,
	|	ЗаявкиОтправлено.Цена,
	|	ЗаявкаСтроки.Номенклатура,
	|	ЗаявкаСтроки.Приоритет,
	|	ЗаявкаСтроки.ПереченьЗакупа
	|ИЗ
	|	РегистрСведений.ЗаявкиОтправлено КАК ЗаявкиОтправлено
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗаявкаСтроки КАК ЗаявкаСтроки
	|		ПО ЗаявкиОтправлено.ИдСтроки = ЗаявкаСтроки.ИдСтроки
	|ГДЕ
	|	(ЗаявкиОтправлено.Менеджер = &Менеджер
	|			ИЛИ &Менеджер = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка))";
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьТекстЗапросаТендер() Экспорт
	
	Возврат
	"ВЫБРАТЬ
	|	ЗаявкиТендер.Регистратор,
	|	ЗаявкиТендер.НомерСтроки,
	|	ЗаявкиТендер.Активность,
	|	ЗаявкиТендер.ИдентификаторСтроки,
	|	ЗаявкиТендер.Контрагент,
	|	ЗаявкиТендер.ЛогОтправлено,
	|	ЗаявкиТендер.Номенклатура,
	|	ЗаявкиТендер.НоменклатураСтрокой,
	|	ЗаявкиТендер.Цена,
	|	ЗаявкиТендер.ДатаСобытия,
	|	ЗаявкиТендер.СрокПоставки,
	|	ЗаявкиТендер.Комментарий КАК Примечание,
	|	ЗаявкиТендер.Аналог,
	|	ЗаявкиТендер.ПричинаОтмены,
	|	ЗаявкиТендер.НаСогласованииУЗаказчика,
	|	ЗаявкиТендер.ДтЗаказчикСогласовал
	|ИЗ
	|	РегистрСведений.ЗаявкаТендер КАК ЗаявкиТендер";
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьТекстЗапросаОтвет() Экспорт
	
	Возврат
	"ВЫБРАТЬ
	|	ЗаявкиТендер.Регистратор,
	|	ЗаявкиТендер.НомерСтроки,
	|	ЗаявкиТендер.Активность,
	|	ЗаявкиТендер.ИдентификаторСтроки,
	|	ЗаявкиТендер.Контрагент,
	|	ЗаявкиТендер.ЛогОтправлено,
	|	ЗаявкиТендер.Номенклатура,
	|	ЗаявкиТендер.НоменклатураСтрокой,
	|	ЗаявкиТендер.Цена,
	|	ЗаявкиТендер.ДатаСобытия,
	|	ЗаявкиТендер.СрокПоставки,
	|	ЗаявкиТендер.Комментарий КАК Примечание,
	|	ЗаявкиТендер.Аналог,
	|	ЗаявкиТендер.ПричинаОтмены,
	|	ЗаявкиТендер.НаСогласованииУЗаказчика,
	|	ЗаявкиТендер.ДтЗаказчикСогласовал
	|ИЗ
	|	РегистрСведений.ЗаявкаТендер КАК ЗаявкиТендер";
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьТекстЗапросаОтмененные() Экспорт
	
	Возврат
	"ВЫБРАТЬ
	|	ЗаявкаСтрокиОтмененные.ИдСтроки,
	|	ЗаявкаСтрокиОтмененные.Менеджер КАК Сотрудник,
	|	ЗаявкаСтрокиОтмененные.ЛогОтправлено,
	|	ЗаявкаСтрокиОтмененные.Причина,
	|	ЗаявкаСтроки.Номенклатура,
	|	ЗаявкаСтроки.Количество,
	|	ЗаявкаСтроки.Приоритет,
	|	ЗаявкаСтроки.Регистратор.Номер КАК НомерЗаявки,
	|	ЗаявкаСтроки.ПереченьЗакупа,
	|	ЗаявкаСтроки.Приоритет КАК Приоритет1
	|ИЗ
	|	РегистрСведений.ЗаявкаСтрокиНаОтмену КАК ЗаявкаСтрокиОтмененные
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ЗаявкаСтроки КАК ЗаявкаСтроки
	|		ПО ЗаявкаСтрокиОтмененные.ИдСтроки = ЗаявкаСтроки.ИдСтроки
	|ГДЕ
	|	ЗаявкаСтроки.ПереченьЗакупа В(&ПеречниЗакупа)
	|	И (ЗаявкаСтроки.Менеджер = &Менеджер
	|			ИЛИ &Менеджер = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка))";
	
КонецФункции

&НаСервере
Процедура ЗаполнитьТаблицу(Таблица, Отбор=Неопределено)
	
	Если Отбор=Неопределено Тогда
		Отбор = Новый Структура("Перечень1, Перечень2, Перечень3", Ложь, Ложь, Истина);
	КонецЕсли;
	
	ПеречниЗакупа = Новый Массив;
	Для Каждого ПереченьОтбора Из Отбор Цикл
		Если Лев(ПереченьОтбора.Ключ, 8) = "Перечень" И ПереченьОтбора.Значение Тогда
			ПеречниЗакупа.Добавить(Число(Прав(ПереченьОтбора.Ключ, 1)));
		КонецЕсли;
	КонецЦикла;
	
	Если ПеречниЗакупа.Количество()=0 Тогда
		ПеречниЗакупа.Добавить(1);
		ПеречниЗакупа.Добавить(2);
		ПеречниЗакупа.Добавить(3);
	КонецЕсли;
	
	Менеджер = ?(Отбор.Свойство("Менеджер"), Отбор.Менеджер, Справочники.Пользователи.ПустаяСсылка());
	
	СтрокиТаблицы = Объект["Строки"+Таблица];
	СтрокиТаблицы.Очистить();
	
	Запрос = Новый Запрос(Вычислить("ПолучитьТекстЗапроса"+Таблица+"()"));
	Запрос.УстановитьПараметр("ПеречниЗакупа", ПеречниЗакупа);
	Запрос.УстановитьПараметр("Менеджер", Менеджер);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если Не РезультатЗапроса.Пустой() Тогда
		СтрокиТаблицы.Загрузить(РезультатЗапроса.Выгрузить());
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТаблицы(Отбор)
	
	ЗаполнитьТаблицу("Необработанные", Отбор);
	//ЗаполнитьТаблицу("Отправленные"  , Отбор);
	//ЗаполнитьТаблицу("Тендер"        , Отбор);
	//ЗаполнитьТаблицу("Отмененные"    , Отбор);
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьОтбор()
	
	Возврат Новый Структура("Перечень1, Перечень2, Перечень3, Менеджер", Элементы.ФормаПеречень1.Пометка, Элементы.ФормаПеречень2.Пометка, Элементы.ФормаПеречень3.Пометка, Объект.Менеджер);
	
КонецФункции

&НаСервере
Процедура ЗаполнитьКонтрагентовДляОтправки()
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ЗаявкаОтправленныеПоставщикам.Контрагент КАК Контрагент,
	|	ВЫРАЗИТЬ(ЗаявкаОтправленныеПоставщикам.Адрес КАК СТРОКА(100)) КАК EMail,
	|	ЗаявкаОтправленныеПоставщикам.ГруппаНоменклатуры КАК Группа
	|ИЗ
	|	РегистрСведений.ЗаявкаОтправленныеПоставщикам.СрезПоследних(, ) КАК ЗаявкаОтправленныеПоставщикам"
	);
	
	ТаблицаДанных = Запрос.Выполнить().Выгрузить();
	
	Объект.КонтрагентыДляОтправки.Загрузить(ТаблицаДанных);
	
	ТаблицаДанных.Свернуть("Группа");
	
	КореньДерева = ДеревоНоменклатуры.ПолучитьЭлементы();
	
	Для Каждого СтрокаДанных Из ТаблицаДанных Цикл
		
		НоваяГруппа = КореньДерева.Добавить();
		НоваяГруппа.Номенклатура = СтрокаДанных.Группа;
		НоваяГруппа.ЭтоГруппа    = Истина;
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ПереченьОтбор(Команда)
	
	Элементы["Форма"+Команда.Имя].Пометка = Не Элементы["Форма"+Команда.Имя].Пометка;
	
	ЗаполнитьТаблицы(ПолучитьОтбор());
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкиEMail(Команда)
	
	ПараметрыНастройкиEMail = Новый Структура();
	ОткрытьФорму(СтрЗаменить(ИмяФормы, "Форма.Форма", "Форма.ФормаНастройкиEMail"), ПараметрыНастройкиEMail, ЭтаФорма,,,,, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

#КонецОбласти // ДополнительныеФункцииПроцедуры

&НаКлиенте
Процедура МенеджерПриИзменении(Элемент)
	
	ЗаполнитьТаблицы(ПолучитьОтбор());
	
КонецПроцедуры

&НаКлиенте
Процедура СтрокиТендерПриАктивизацииСтроки(Элемент)
	
	//ЗаполнитьТаблицу("Контрагенты", Новый Структура("ИдСтроки", ));
	
КонецПроцедуры

&НаКлиенте
Процедура СтрокиКонтрагентыДляОтправкиEMailНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	//СтандартнаяОбработка = Ложь;
	//
	//Форма = ОткрытьФорму("Обработка.ОпросПоставщиков.Форма.ФормаПодборКА",, ЭтаФорма, Элемент);
	//Форма.РежимВыбора = Истина;
	//Форма.ЗакрыватьПриВыборе = Истина;
	////Форма.ТекМенеджер = Ответственный;
	//Форма.Открыть();
	
КонецПроцедуры

&НаСервере
Процедура СтрокиНеобработанныеНачалоПеретаскиванияНаСервере()
	// Вставить содержимое обработчика.
КонецПроцедуры

#Область КонтрагентыДляОтправки

&НаКлиенте
Процедура КонтрагентыДляОтправкиПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	Если НоваяСтрока И Не Копирование Тогда
		Элемент.ТекущиеДанные.Группа = Элемент.ОтборСтрок.Группа;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура КонтрагентыДляОтправкиПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	
	Отказ = (Элементы.ДеревоНоменклатуры.ТекущиеДанные=Неопределено);
	
КонецПроцедуры

#КонецОбласти // КонтрагентыДляОтправки

#Область ОтправитьПочту

&НаСервере
Процедура ОтправитьПочтуНаСервере()
	
	Организация = Справочники.Организации.ОрганизацияПоУмолчанию().Наименование;
	Организация = СтрЗаменить(Организация, "ООО", "");
	Организация = СтрЗаменить(Организация, """", "");
	Организация = СокрЛП(Организация);
	
	ТаблицаДанных = Новый ТаблицаЗначений;
	ТаблицаДанных.Колонки.Добавить("Контрагент"      , Новый ОписаниеТипов("СправочникСсылка.Контрагенты"));
	ТаблицаДанных.Колонки.Добавить("EMail"           , Новый ОписаниеТипов("Строка"));
	ТаблицаДанных.Колонки.Добавить("Группа"          , Новый ОписаниеТипов("СправочникСсылка.Номенклатура"));
	ТаблицаДанных.Колонки.Добавить("Артикул"         , Новый ОписаниеТипов("Строка"));
	ТаблицаДанных.Колонки.Добавить("Номенклатура"    , Новый ОписаниеТипов("СправочникСсылка.Номенклатура"));
	ТаблицаДанных.Колонки.Добавить("ЕдиницаИзмерения", Новый ОписаниеТипов("СправочникСсылка.КлассификаторЕдиницИзмерения"));
	ТаблицаДанных.Колонки.Добавить("Примечание"      , Новый ОписаниеТипов("Строка"));
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	НоменклатураДляОтправки.ИдСтроки,
	|	НоменклатураДляОтправки.Артикул,
	|	НоменклатураДляОтправки.Номенклатура,
	|	НоменклатураДляОтправки.ЕдиницаИзмерения,
	|	НоменклатураДляОтправки.Примечание,
	|	НоменклатураДляОтправки.Группа
	|ПОМЕСТИТЬ НоменклатураДляОтправки
	|ИЗ
	|	&НоменклатураДляОтправки КАК НоменклатураДляОтправки
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КонтрагентыДляОтправки.Контрагент,
	|	КонтрагентыДляОтправки.EMail,
	|	КонтрагентыДляОтправки.Группа
	|ПОМЕСТИТЬ КонтрагентыДляОтправки
	|ИЗ
	|	&КонтрагентыДляОтправки КАК КонтрагентыДляОтправки
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КонтрагентыДляОтправки.Контрагент,
	|	КонтрагентыДляОтправки.EMail,
	|	НоменклатураДляОтправки.Группа,
	|	НоменклатураДляОтправки.ИдСтроки,
	|	НоменклатураДляОтправки.Артикул,
	|	НоменклатураДляОтправки.Номенклатура,
	|	НоменклатураДляОтправки.ЕдиницаИзмерения,
	|	НоменклатураДляОтправки.Примечание
	|ИЗ
	|	КонтрагентыДляОтправки КАК КонтрагентыДляОтправки
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ НоменклатураДляОтправки КАК НоменклатураДляОтправки
	|		ПО КонтрагентыДляОтправки.Группа = НоменклатураДляОтправки.Группа"
	);
	
	НоменклатураДляОтправки = Объект.СтрокиНеобработанные.Выгрузить().Скопировать(Новый Структура("Выбрана", Истина));
	
	Запрос.УстановитьПараметр("НоменклатураДляОтправки", НоменклатураДляОтправки);
	Запрос.УстановитьПараметр("КонтрагентыДляОтправки", Объект.КонтрагентыДляОтправки.Выгрузить());
	
	РезультатЗапроса = Запрос.Выполнить();
	ТаблицаДанных = РезультатЗапроса.Выгрузить();
	
	ПочтаКонтрагентов = ТаблицаДанных.Скопировать(, "EMail");
	ПочтаКонтрагентов.Свернуть("EMail",);
	
	Обработка = РеквизитФормыВЗначение("Объект");
	Макет = Обработка.ПолучитьМакет("Перечень3");
	
	Для Каждого СтрокаПочты Из ПочтаКонтрагентов Цикл
		
		НайденныеСтроки = ТаблицаДанных.НайтиСтроки(Новый Структура("EMail", СтрокаПочты.EMail));
		
		Если НайденныеСтроки.Количество()=0 Тогда
			Продолжить;
		КонецЕсли;
		
		ТабДок = Новый ТабличныйДокумент;
		ТабДок.Вывести(Макет.ПолучитьОбласть("Шапка"));
		ОбластьСтрока = Макет.ПолучитьОбласть("Строка");
		
		Для Каждого СтрокаНоменклатуры Из НайденныеСтроки Цикл
			ОбластьСтрока.Параметры.Заполнить(СтрокаНоменклатуры);
			ОбластьСтрока.Параметры.НомерСтроки = НайденныеСтроки.Найти(СтрокаНоменклатуры)+1;
			ТабДок.Вывести(ОбластьСтрока);
		КонецЦикла;
		
		
		ИмяФайла = Организация+"_расценка_"+Формат(ТекущаяДата(), "ДФ=yyMMdd_HHmm")+".xlsx";
		
		ТабДок.Записать(КаталогВременныхФайлов()+ИмяФайла, ТипФайлаТабличногоДокумента.XLSX);
		
		//глЗаявкиРаботаСПочтойКлиент.Почта(СтрокаПочты.EMail, ПочтаПользователя, ТемаПисьма, ТекстПисьма, КаталогВременныхФайлов()+ИмяФайла);
		
		//УдалитьФайлы(КаталогВременныхФайлов(), ИмяФайла);
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтправитьПочту(Команда)
	
	ОтправитьПочтуНаСервере();
	
	//ОтправкаПочтовыхСообщенийКлиент.ОтправитьОтчет(ЭтаФорма, );
	
КонецПроцедуры

#КонецОбласти // ОтправитьПочту

#Область ДеревоНоменклатуры

&НаСервере
Процедура РаспределитьПоГруппамНаСервере()
	
	Для Каждого СтрокаНеобработанная Из Объект.СтрокиНеобработанные Цикл
		Если Не СтрокаНеобработанная.Выбрана Тогда
			ПеренестиНоменклатуру(СтрокаНеобработанная.Номенклатура);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура РаспределитьПоГруппам(Команда)
	
	РаспределитьПоГруппамНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьОтборИНадпись(ТекущаяСтрока)
	
	Если ТекущаяСтрока = Неопределено Тогда
		Группа = Неопределено;
	Иначе
		ГруппаДерева = ДеревоНоменклатуры.НайтиПоИдентификатору(ТекущаяСтрока);
		Если Не ГруппаДерева.ЭтоГруппа Тогда
			ГруппаДерева = ГруппаДерева.ПолучитьРодителя();
		КонецЕсли;
		Группа = ГруппаДерева.Номенклатура;
	КонецЕсли;
	
	Если Элементы.КонтрагентыДляОтправки.ОтборСтрок = Неопределено
	 Или Элементы.КонтрагентыДляОтправки.ОтборСтрок.Группа <> Группа Тогда
		Элементы.КонтрагентыДляОтправки.ОтборСтрок = Новый ФиксированнаяСтруктура("Группа", ?(Группа=Неопределено, 0, Группа));
		ИнформационнаяСтрокаДляОтправки = ?(Группа=Неопределено, "< создается автоматически >", ?(ПустаяСтрока(Группа), "< пустая группа >", Строка(Группа)));
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДеревоНоменклатурыПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	
	Отказ = Истина;
	
	Форма = ПолучитьФорму("Справочник.Номенклатура.ФормаВыбораГруппы");
	ГруппаНоменклатуры = Форма.ОткрытьМодально();
	
	Если ГруппаНоменклатуры <> Неопределено Тогда
		
		Для Каждого СтрокаГруппы Из ДеревоНоменклатуры.ПолучитьЭлементы() Цикл
			Если СтрокаГруппы.Номенклатура = ГруппаНоменклатуры Тогда
				ПоказатьПредупреждение(, "Группа """+ГруппаНоменклатуры+""" - уже есть!");
				Возврат;
			КонецЕсли;
		КонецЦикла;
		
		ГруппаДерева = ДеревоНоменклатуры.ПолучитьЭлементы().Добавить();
		ГруппаДерева.Номенклатура = ГруппаНоменклатуры;
		ГруппаДерева.ЭтоГруппа    = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДеревоНоменклатурыПриАктивизацииСтроки(Элемент)
	
	УстановитьОтборИНадпись(Элемент.ТекущаяСтрока);
	
КонецПроцедуры

&НаКлиенте
Процедура ДеревоНоменклатурыПередНачаломИзменения(Элемент, Отказ)
	
	Отказ = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ДеревоНоменклатурыПриСменеТекущегоРодителя(Элемент)
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаСервере
Процедура ДеревоНоменклатурыПередУдалениемНаСервере(ИдентификаторСтроки)
	
	МассивНоменклатуры = Новый Массив;
	
	ТекущиеДанные = ДеревоНоменклатуры.НайтиПоИдентификатору(ИдентификаторСтроки);
	
	Если ТекущиеДанные.ЭтоГруппа Тогда
		Для Каждого СтрокаДерева Из ТекущиеДанные.ПолучитьЭлементы() Цикл
			МассивНоменклатуры.Добавить(СтрокаДерева.Номенклатура);
		КонецЦикла;
	Иначе
		МассивНоменклатуры.Добавить(ТекущиеДанные.Номенклатура);
	КонецЕсли;
	
	Для Каждого Номенклатура Из МассивНоменклатуры Цикл
		НайденныеСтроки = Объект.СтрокиНеобработанные.НайтиСтроки(Новый Структура("Номенклатура", Номенклатура));
		Для Каждого СтрокаНоменклатуры Из НайденныеСтроки Цикл
			СтрокаНоменклатуры.Выбрана = Ложь;
			СтрокаНоменклатуры.Группа  = Справочники.Номенклатура.ПустаяСсылка();
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ДеревоНоменклатурыПередУдалением(Элемент, Отказ)
	
	ДеревоНоменклатурыПередУдалениемНаСервере(Элемент.ТекущаяСтрока);
	
КонецПроцедуры

&НаКлиенте
Процедура ДеревоНоменклатурыПослеУдаления(Элемент)
	
	УстановитьОтборИНадпись(Элемент.ТекущаяСтрока);
	
КонецПроцедуры

#КонецОбласти // ДеревоНоменклатуры

#Область Контрагенты

&НаСервереБезКонтекста
Функция ПолучитьПочтуКонтрагента(Контрагент, Массивом=Ложь)
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	ЗаявкиПользователиПароли.Емайл
	|ИЗ
	|	РегистрСведений.ЗаявкиПользователиПароли КАК ЗаявкиПользователиПароли
	|ГДЕ
	|	ЗаявкиПользователиПароли.Контрагент = &Контрагент"
	);
	
	Запрос.УстановитьПараметр("Контрагент", Контрагент);
	
	МассивДанных = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Емайл");
	
	Если Массивом Тогда
		Возврат МассивДанных;
	ИначеЕсли МассивДанных.Количество()=0 Тогда
		Возврат "";
	Иначе
		Возврат МассивДанных[0];
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Процедура СтрокиКонтрагентыДляОтправкиEMailНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	
	Элемент.СписокВыбора.ЗагрузитьЗначения(ПолучитьПочтуКонтрагента(Элементы.КонтрагентыДляОтправки.ТекущиеДанные.Контрагент, Истина));
	
КонецПроцедуры

&НаКлиенте
Процедура СтрокиКонтрагентыДляОтправкиКонтрагентПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.КонтрагентыДляОтправки.ТекущиеДанные;
	
	ТекущиеДанные.EMail = ПолучитьПочтуКонтрагента(ТекущиеДанные.Контрагент);
	
КонецПроцедуры

#КонецОбласти // Контрагенты
