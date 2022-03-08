#! /bin/bash
#
# Copyright(c) 2011- Brother Industries, Ltd.  
#    All Rights Reserved.
#
#Brother retains any and all copyrights to the Software. 
#In no case this Agreement shall be construed to assign 
#or otherwise transfer from Brother to User any copyrights 
#or other intellectual property rights to whole or any part 
#of the Software.
#
#Brother grants User a non-exclusive license: to reproduce 
#and/or distribute (via Internet or in any other manner) the 
#Software. Further, Brother grants User a non-exclusive 
#license to modify, alter, translate or otherwise prepare 
#derivative works of the Software and to reproduce and 
#distribute (via Internet or in any other manner) such 
#modification, alteration, translation or other derivative 
#works for any purpose.
#
#The license of the Software from Brother hereunder is 
#granted "AS IS." BROTHER HEREBY DISCLAIMS ANY WARRANTIES WITH
# RESPECT TO THE SOFTWARE, EXPRESS OR IMPLIED, INCLUDING 
#BUT NOT LIMITED TO WARRANTY FOR THE QUALITY, MERCHANTABILITY, 
#FITNESS FOR PARTICULAR PURPOSE OR NON-INFRINGEMENT.
#Brother shall have no liability in contract, tort (including 
#negligence or breach of statutory duty) or otherwise for any 
#interruption of use, loss of data, or for any indirect, 
#incidental, punitive or consequential loss or damage, or for 
#any loss of profit, revenue, data, goodwill or anticipated 
#savings that arises under, out of, or in contemplation of 
#this Agreement or otherwise arises due to any error, inaccuracy 
#or defect in the Software even if Brother has been advised of 
#the possibility of such loss or damage.
#Further, Brother shall have no liability to disclose and/or 
#distribute the source cord of the Software to User under any 
#circumstances. In no case shall the above license by Brother 
#to modify, alter, translate or otherwise prepare derivative 
#works of the Software be construed as Brother's implied 
#agreement or undertakings to disclose and/or distribute the 
#source cord of the Software.


DEBUG_MSG=0
MSG=1


COLOR='\033[1;31m'
COLOR2='\033[1;35m'
COLOR3='\033[1;32m'
COLOR4='\033[1;34m'
MONO='\033[1;0m'

if [ "$(echo $0 | grep  linux-brjprinter-installer)" = '' ];then
  MESSAGE010="USAGE:  "
  MESSAGE012="     :  "
  MESSAGE020="  model"
  MESSAGE030="   -f model"
  MESSAGE040="   -l "
  MESSAGE050="Only root can perform this operation."
  MESSAGE060="CUPS is not installed."
  MESSAGE070="Do you want to specify a PROXY server? [y/N] ->"
  MESSAGE080="Enter the URL of the PROXY server."
  MESSAGE090="   ex https://(proxy-server-url):(port)"
  MESSAGE100="   ex https://(login-name):(password)@(proxy-server-url):(port)"
  MESSAGE110="     ->"
  MESSAGE120="Unable to get the server information."\
"  Please check the network settings."
  MESSAGE121="Input model name ->"
  MESSAGE122="Rpm or dpkg is required."
  MESSAGE130="Driver-packages cannot be found."
  MESSAGE140=" Confirm the model name."
  MESSAGE150="You are going to install  following packages."
  MESSAGE160="OK? [y/N]  ->"
  MESSAGE165="OK? [Y/n]  ->"
  MESSAGE170="Do you agree? [Y/n] ->"
  MESSAGE180="Do you agree? [Y/n] ->"
  MESSAGE184="The security level of AppArmor has been lowered."\
"  (aa-complain cups)"
  MESSAGE190="Will you specify the Device URI? [Y/n] ->"
  MESSAGE200="Specify IP address."
  MESSAGE201="Auto."
  MESSAGE210="select the number of destination Device URI. ->"
  MESSAGE220="  enter IP address ->"
  MESSAGE230="Test Print? [y/N] ->"
  MESSAGE240="Hit Enter/Return key."
  MESSAGE250="csh/tcsh is required"
  MESSAGE280="wget is required."
else
  MESSAGE010="使用方法:  "
  MESSAGE012="　　　　:  "
  MESSAGE020="  モデル名"
  MESSAGE030="   -f モデル名"
  MESSAGE040="   -l "
  MESSAGE050="権限がありません。suもしくはsudoコマンドでroot権限を取得してください。"
  MESSAGE060="CUPSがインストールされていません。"
  MESSAGE070="WEBより情報を取得できません。PROXYサーバーを指定しますか? [y/N] ->"
  MESSAGE080="PROXYサーバーのURLを入力してください。"
  MESSAGE090="   例1 https://(proxy-server-url):(port)"
  MESSAGE100="   例2 https://(login-name):(pass-word)@(proxy-server-url):(port)"
  MESSAGE110="     ->"
  MESSAGE120="インターネットに接続できません。ネットワーク設定を確認してください。"
  MESSAGE121="モデル名を入力してください。->"
  MESSAGE122="rpmもしくはdpkgが必要です。"
  MESSAGE130="該当するドライバパッケージが見つかりません。"
  MESSAGE140="　　モデル名を確認してください。"
  MESSAGE150="以下のパッケージが見付かりました。"
  MESSAGE160="インストールしますか? [y/N]  ->"
  MESSAGE165="インストールしますか? [Y/n]  ->"
  MESSAGE170="上記使用許諾に同意しますか? [Y/n] ->"
  MESSAGE180="上記使用許諾に同意しますか? [Y/n] ->"
  MESSAGE184="AppArmorのCUPSに対するセキュリティレベルを下げました (aa-complain cups)。"
  MESSAGE190="Device URIを指定しますか? [Y/n] ->"
  MESSAGE200="IPアドレスの指定"
  MESSAGE201="自動設定"
  MESSAGE210="使用するDevice URIの番号を選択してください。 ->"
  MESSAGE220="  ご使用のプリンタ/MFCのIPアドレスを指定してください。->"
  MESSAGE230="テスト印刷を実行しますか? [y/N] ->"
  MESSAGE240="Enterキーを押してください。"
  MESSAGE250="csh/tcsh が必要です。"
  MESSAGE280="'wget'が必要です。"
fi

if [ -e "$0".rc ];then
  source "$0".rc
fi


brother_license(){
echo -e $COLOR2
if [ $REGION != JPN ];then
  cat <<BROTHERLICENSE
=========================================
Brother License Agreement

Brother retains any and all copyrights to the Software. In no case this Agreement shall be construed to assign or otherwise transfer from Brother to User any copyrights or other intellectual property rights to whole or any part of the Software.

Brother grants User a non-exclusive license: to reproduce and/or distribute (via Internet or in any other manner) the Software. Further, Brother grants User a non-exclusive license to modify, alter, translate or otherwise prepare derivative works of the Software and to reproduce and distribute (via Internet or in any other manner) such modification, alteration, translation or other derivative works for any purpose.

The license of the Software from Brother hereunder is granted "AS IS." BROTHER HEREBY DISCLAIMS ANY WARRANTIES WITH RESPECT TO THE SOFTWARE, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTY FOR THE QUALITY, MERCHANTABILITY, FITNESS FOR PARTICULAR PURPOSE OR NON-INFRINGEMENT.
Brother shall have no liability in contract, tort (including negligence or breach of statutory duty) or otherwise for any interruption of use, loss of data, or for any indirect, incidental, punitive or consequential loss or damage, or for any loss of profit, revenue, data, goodwill or anticipated savings that arises under, out of, or in contemplation of this Agreement or otherwise arises due to any error, inaccuracy or defect in the Software even if Brother has been advised of the possibility of such loss or damage.
Further, Brother shall have no liability to disclose and/or distribute the source cord of the Software to User under any circumstances. In no case shall the above license by Brother to modify, alter, translate or otherwise prepare derivative works of the Software be construed as Brother's implied agreement or undertakings to disclose and/or distribute the source cord of the Software.
=========================================
BROTHERLICENSE
else
  cat <<BROTHERLICENSEJ
=========================================
﻿ブラザーソフトウェア用　公衆使用許諾契約書

本契約は、本契約とともに配布・提供されるソフトウェア （以下単に本ソフトウェアといいます） に関し、本ソフトウェアの著作権者であるブラザー工業株式会社 （以下、ブラザーといいます） から本ソフトウェア受領者 （以下単に利用者といいます） に対し与えられる使用許諾について定めるものです。 利用者は、下記条項に従い本ソフトウェアを利用するものとします。 また、利用者は本ソフトウェアを利用することにより、下記条項に同意したものと見なされます。

（１）本ソフトウェアに関する著作権は、ブラザーに帰属します。 本契約は、本ソフトウェアについてブラザーから利用者に対し著作権の全部若しくは一部を譲渡するものとは解され得ません。 
（２）ブラザーは利用者に対し、本ソフトウェアについて複製、譲渡 （著作権の譲渡ではなくソフトウェアが格納された媒体の譲渡を指します） および公衆送信を行う権利を無償にて非独占的に許諾します。 
（３）さらにブラザーは利用者に対し、いかなる目的のためにでも本ソフトウェアを変更、改変、翻訳あるいは本ソフトウェアの派生物を作成し、かつそれらについて複製、譲渡及び公衆送信を行う権利を無償にて非独占的に許諾します。 
（４）ブラザーによる本ソフトウェアの配布・提供は、現状有姿にて行われるものであり、ブラザーは利用者に対し、本ソフトウェアに関し、明示・黙示問わず、何らの保証 （品質保証・有用性に関する保証・特定目的への合致に関する保証その他一切含め） も行いません。 
（５）ブラザーは本ソフトウェアに関し、利用者に生じたいかなる損害 （直接損害・間接損害・特別損害・派生損害・懲罰的損害その他一切含め） についても、かかる損害が予測可能か否か、また、その可能性についてブラザーが知っていたか否かを問わず、賠償義務を負いません。 
（６）さらにブラザーは利用者に対し、いかなる場合も本ソフトウェアのソースコードを開示する義務を負いません。 上記ブラザーによる変更、改変、翻訳あるいは本ソフトウェアの派生物作成に関するライセンスは、いかなる場合にも、本ソフトウェアのソースコード開示に関するブラザーの黙示的な同意とは解釈されません。 

=========================================
BROTHERLICENSEJ
  echo -e $MONO
fi
}


gpl_license(){
echo -e $COLOR2
cat <<GPLLICENSE
=========================================
GPL License Agreement

This Software may be used in accordance with GNU General Public License (GPL). Please read carefully the following GPL and click on "I Accept" button. If you cannot agree with the following terms, please click "I don't Accept" button. In case of your non-acceptance, you can not use this Software.
Note:
Please click on "I Accept" while holding down "Shift" or right click on "I Accept" and select "Save Target As,,," from the menu.

GNU GENERAL PUBLIC LICENSE
Version 2, June 1991

Copyright (C) 1989, 1991 Free Software Foundation, Inc.51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
Everyone is permitted to copy and distribute verbatim copies of this license document, but changing it is not allowed.

Preamble

The licenses for most software are designed to take away your freedom to share and change it. By contrast, the GNU General Public License is intended to guarantee your freedom to share and change free software--to make sure the software is free for all its users. This General Public License applies to most of the Free Software Foundation's software and to any other program whose authors commit to using it. (Some other Free Software Foundation software is covered by
the GNU Library General Public License instead.) You can apply it to your programs, too.

When we speak of free software, we are referring to freedom, not price. Our General Public Licenses are designed to make sure that you have the freedom to distribute copies of free software (and charge for this service if you wish), that you receive source code or can get it if you want it, that you can change the software or use pieces of it in new free programs; and that you know you can do these things.

To protect your rights, we need to make restrictions that forbid anyone to deny you these rights or to ask you to surrender the rights. These restrictions translate to certain responsibilities for you if you distribute copies of the software, or if you modify it.

For example, if you distribute copies of such a program, whether gratis or for a fee, you must give the recipients all the rights that you have. You must make sure that they, too, receive or can get the
source code. And you must show them these terms so they know their rights.

We protect your rights with two steps: (1) copyright the software, and (2) offer you this license which gives you legal permission to copy, distribute and/or modify the software.

Also, for each author's protection and ours, we want to make certain that everyone understands that there is no warranty for this free software. If the software is modified by someone else and passed on, we want its recipients to know that what they have is not the original, so that any problems introduced by others will not reflect on the original authors' reputations.

Finally, any free program is threatened constantly by software patents. We wish to avoid the danger that redistributors of a free program will individually obtain patent licenses, in effect making the program proprietary. To prevent this, we have made it clear that any patent must be licensed for everyone's free use or not licensed at all.

The precise terms and conditions for copying, distribution and modification follow.

GNU GENERAL PUBLIC LICENSE
TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

0. This License applies to any program or other work which contains a notice placed by the copyright holder saying it may be distributed under the terms of this General Public License. The "Program", below, refers to any such program or work, and a "work based on the Program" means either the Program or any derivative work under copyright law: that is to say, a work containing the Program or a portion of it, either verbatim or with modifications and/or translated into another language. (Hereinafter, translation is included without limitation in the term "modification".) Each licensee is addressed as "you".

Activities other than copying, distribution and modification are not covered by this License; they are outside its scope. The act of running the Program is not restricted, and the output from the Program
is covered only if its contents constitute a work based on the Program (independent of having been made by running the Program). Whether that is true depends on what the Program does.

   1. You may copy and distribute verbatim copies of the Program's source code as you receive it, in any medium, provided that you conspicuously and appropriately publish on each copy an appropriate copyright notice and disclaimer of warranty; keep intact all the notices that refer to this License and to the absence of any warranty; and give any other recipients of the Program a copy of this License along with the Program.

      You may charge a fee for the physical act of transferring a copy, and you may at your option offer warranty protection in exchange for a fee.
   2. You may modify your copy or copies of the Program or any portion of it, thus forming a work based on the Program, and copy and distribute such modifications or work under the terms of Section 1 above, provided that you also meet all of these conditions:

      a) You must cause the modified files to carry prominent notices stating that you changed the files and the date of any change.

      b) You must cause any work that you distribute or publish, that in whole or in part contains or is derived from the Program or any part thereof, to be licensed as a whole at no charge to all third parties under the terms of this License.

      c) If the modified program normally reads commands interactively when run, you must cause it, when started running for such interactive use in the most ordinary way, to print or display an
      announcement including an appropriate copyright notice and a notice that there is no warranty (or else, saying that you provide a warranty) and that users may redistribute the program under these conditions, and telling the user how to view a copy of this License. (Exception: if the Program itself is interactive but does not normally print such an announcement, your work based on the Program is not required to print an announcement.)
      
      These requirements apply to the modified work as a whole. If identifiable sections of that work are not derived from the Program, and can be reasonably considered independent and separate works in themselves, then this License, and its terms, do not apply to those sections when you distribute them as separate works. But when you distribute the same sections as part of a whole which is a work based on the Program, the distribution of the whole must be on the terms of this License, whose permissions for other licensees extend to the entire whole, and thus to each and every part regardless of who wrote it.

      Thus, it is not the intent of this section to claim rights or contest your rights to work written entirely by you; rather, the intent is to exercise the right to control the distribution of derivative or collective works based on the Program.

      In addition, mere aggregation of another work not based on the Program with the Program (or with a work based on the Program) on a volume of a storage or distribution medium does not bring the other work under the scope of this License.
   3. You may copy and distribute the Program (or a work based on it, under Section 2) in object code or executable form under the terms of Sections 1 and 2 above provided that you also do one of the following:

      a) Accompany it with the complete corresponding machine-readable source code, which must be distributed under the terms of Sections 1 and 2 above on a medium customarily used for software interchange; or,

      b) Accompany it with a written offer, valid for at least three years, to give any third party, for a charge no more than your cost of physically performing source distribution, a complete machine-readable copy of the corresponding source code, to be distributed under the terms of Sections 1 and 2 above on a medium customarily used for software interchange; or,

      c) Accompany it with the information you received as to the offer to distribute corresponding source code. (This alternative is allowed only for noncommercial distribution and only if you
      received the program in object code or executable form with such an offer, in accord with Subsection b above.)

      The source code for a work means the preferred form of the work for making modifications to it. For an executable work, complete source code means all the source code for all modules it contains, plus any associated interface definition files, plus the scripts used to control compilation and installation of the executable. However, as a special exception, the source code distributed need not include anything that is normally distributed (in either source or binary form) with the major components (compiler, kernel, and so on) of the operating system on which the executable runs, unless that component itself accompanies the executable.

      If distribution of executable or object code is made by offering access to copy from a designated place, then offering equivalent access to copy the source code from the same place counts as distribution of the source code, even though third parties are not compelled to copy the source along with the object code.
   4. You may not copy, modify, sublicense, or distribute the Program except as expressly provided under this License. Any attempt otherwise to copy, modify, sublicense or distribute the Program is void, and will automatically terminate your rights under this License. However, parties who have received copies, or rights, from you under this License will not have their licenses terminated so long as such parties remain in full compliance.
   5. You are not required to accept this License, since you have not signed it. However, nothing else grants you permission to modify or distribute the Program or its derivative works. These actions are prohibited by law if you do not accept this License. Therefore, by modifying or distributing the Program (or any work based on the Program), you indicate your acceptance of this License to do so, and all its terms and conditions for copying, distributing or modifying
      the Program or works based on it.
   6. Each time you redistribute the Program (or any work based on the Program), the recipient automatically receives a license from the original licensor to copy, distribute or modify the Program subject to these terms and conditions. You may not impose any further restrictions on the recipients' exercise of the rights granted herein. You are not responsible for enforcing compliance by third parties to this License.
   7. If, as a consequence of a court judgment or allegation of patent infringement or for any other reason (not limited to patent issues), conditions are imposed on you (whether by court order, agreement or otherwise) that contradict the conditions of this License, they do not excuse you from the conditions of this License. If you cannot distribute so as to satisfy simultaneously your obligations under this License and any other pertinent obligations, then as a consequence you may not distribute the Program at all. For example, if a patent license would not permit royalty-free redistribution of the Program by all those who receive copies directly or indirectly through you, then the only way you could satisfy both it and this License would be to refrain entirely from distribution of the Program.

      If any portion of this section is held invalid or unenforceable under any particular circumstance, the balance of the section is intended to apply and the section as a whole is intended to apply in other circumstances.

      It is not the purpose of this section to induce you to infringe any patents or other property right claims or to contest validity of any such claims; this section has the sole purpose of protecting the integrity of the free software distribution system, which is implemented by public license practices. Many people have made generous contributions to the wide range of software distributed through that system in reliance on consistent application of that system; it is up to the author/donor to decide if he or she is willing to distribute software through any other system and a licensee cannot impose that choice.

      This section is intended to make thoroughly clear what is believed to be a consequence of the rest of this License.
   8. If the distribution and/or use of the Program is restricted in certain countries either by patents or by copyrighted interfaces, the original copyright holder who places the Program under this License may add an explicit geographical distribution limitation excluding those countries, so that distribution is permitted only in or among countries not thus excluded. In such case, this License incorporates the limitation as if written in the body of this License.
   9. The Free Software Foundation may publish revised and/or new versions of the General Public License from time to time. Such new versions will be similar in spirit to the present version, but may differ in detail to address new problems or concerns.

      Each version is given a distinguishing version number. If the Program specifies a version number of this License which applies to it and "any later version", you have the option of following the terms and conditions either of that version or of any later version published by the Free Software Foundation. If the Program does not specify a version number of this License, you may choose any version ever published by the Free Software Foundation.
  10. If you wish to incorporate parts of the Program into other free programs whose distribution conditions are different, write to the author to ask for permission. For software which is copyrighted by the Free Software Foundation, write to the Free Software Foundation; we sometimes make exceptions for this. Our decision will be guided by the two goals of preserving the free status of all derivatives of our free software and of promoting the sharing and reuse of software generally.

NO WARRANTY

  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.
  12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

END OF TERMS AND CONDITIONS

How to Apply These Terms to Your New Programs

If you develop a new program, and you want it to be of the greatest possible use to the public, the best way to achieve this is to make it free software which everyone can redistribute and change under these terms.

To do so, attach the following notices to the program. It is safest to attach them to the start of each source file to most effectively convey the exclusion of warranty; and each file should have at least the "copyright" line and a pointer to where the full notice is found.

<one line to give the program's name and a brief idea of what it does.>
Copyright (C) <year> <name of author>

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA


Also add information on how to contact you by electronic and paper mail.

If the program is interactive, make it output a short notice like this when it starts in an interactive mode:

Gnomovision version 69, Copyright (C) year name of author Gnomovision
comes with ABSOLUTELY NO WARRANTY; for details type \`show w'.
This is free software, and you are welcome to redistribute it
under certain conditions; type \`show c' for details.

The hypothetical commands \`show w' and \`show c' should show the appropriate parts of the General Public License. Of course, the commands you use may be called something other than \`show w' and \`show c'; they could even be mouse-clicks or menu items--whatever suits your program.

You should also get your employer (if you work as a programmer) or your school, if any, to sign a "copyright disclaimer" for the program, if necessary. Here is a sample; alter the names:

Yoyodyne, Inc., hereby disclaims all copyright interest in the program
\`Gnomovision' (which makes passes at compilers) written by James Hacker.

<signature of Ty Coon>, 1 April 1989
Ty Coon, President of Vice

This General Public License does not permit incorporating your program into proprietary programs. If your program is a subroutine library, you may consider it more useful to permit linking proprietary applications with the library. If this is what you want to do, use the GNU Library General Public License instead of this License.
=========================================
GPLLICENSE
  echo -e $MONO
}






gpl_and_br_license(){
    echo -e $COLOR2
    if [ $REGION = JPN ];then
	cat <<GPLBROTHERLICENSE_J
本契約は、本契約とともに配布・提供されるソフトウェア（以下単に本ソフトウェアといいます）に関し、ブラザー工業株式会社（以下、ブラザーといいます）から本ソフトウェア受領者（以下、お客様といいます）に対し与えられる使用許諾について定めるものです。

1.本ソフトウェアは、以下のモジュールから構成されています。
(1) GNU GENERAL PUBLIC LICENSE対象ソフトウェアモジュール（以下、GPL対象モジュールといいます） 
(2) 上記に該当しないソフトウェアモジュール（以下、非GPLモジュールといいます。 
本ソフトウェアを構成する各モジュールが上記のいずれに該当するかについては、本ソフトウェアのソースファイルをダウンロード頂きご確認ください。


2.GPL対象モジュールについては、GNU GENERAL PUBLIC LICENSE Version 2, June 1991（以下GPLv2といいます）の条件が適用されます。その条件の詳細については、 https://support.brother.co.jp/j/s/support/agreement/agree_gpl.html をご確認ください。GPL対象モジュールについては、お客様は、GPLv2に定める条件に従い利用するものとします。また、お客様はGPL対象モジュールを利用することにより、GPLv2に定める条件に同意したものと見なされます。


3.非GPLモジュールについては、下記の条件が適用されます。非GPLモジュールについては、お客様は、下記の条件に従い利用するものとします。また、お客様は非GPLモジュールを利用することにより、下記条件に同意したものと見なされます。
(1) 非GPLモジュールに関する著作権は、ブラザーに帰属します。本契約は、非GPLモジュールについてブラザーからお客様に対し著作権の全部若しくは一部を譲渡するものとは解され得ません。 
(2) ブラザーはお客様に対し、非GPLモジュールについて複製、譲渡（著作権の譲渡ではなくソフトウェアが格納された媒体の譲渡を指します）、公衆送信、および、改変並びに翻案（改変若しくは翻案された非GPLモジュールの複製、譲渡及び公衆送信を含みます）を行う権利を、無償にて非独占的に許諾します。 
(3) お客様は、前号に基づく譲渡及び公衆送信に際し、本契約に定めると同一内容の再使用許諾を受領者に明示的に与えなければなりません。 
(4) ブラザーによる非GPLモジュールの配布・提供は、現状有姿にて行われるものであり、ブラザーはお客様に対し、非GPLモジュールに関し、明示・黙示問わず、何らの保証（品質保証・有用性に関する保証・特定目的への合致に関する保証その他一切含め）も行いません。 
(5) ブラザーは非GPLモジュールに関し、適用法で認められる限り、お客様に生じたいかなる損害（直接損害・間接損害・特別損害・派生損害・懲罰的損害その他一切含め）についても、かかる損害が予測可能か否か、また、その可能性についてブラザーが知っていたか否かを問わず、賠償義務を負いません。 
(6) さらにブラザーはお客様に対し、いかなる場合も非GPLモジュールのソースコードを開示する義務を負いません。上記ブラザーによる改変、翻案に関するライセンスは、いかなる場合にも、非GPLモジュールのソースコード開示に関するブラザーの黙示的な同意とは解釈されません。 

GPLBROTHERLICENSE_J
    else 
	cat <<GPLBROTHERLICENSE_U
This Agreement provides terms and conditions for license grant for use of the software that is distributed with this Agreement ("Software") from Brother Industries, Ltd. ("Brother") to recipients thereof ("You").

Note:
Please click on "I Accept" while holding down "Shift" or right click on "I Accept" and select "Save Target As,,," from the menu. 

1.The Software is comprised of the following software modules:

(1) Certain software modules that is the subject of GNU GENERAL PUBLIC LICENSE ("GPL Modules"), and 
(2) Other software modules ("Non-GPL Modules") 

You may distinguish each of GPL Modules by downloading source files of the Software as Brother separately makes available and reading such files.

2.Your use of all GPL Modules shall be subject to the terms and conditions of GNU GENERAL PUBLIC LICENSE Version 2, June 1991 ("GPLv2"). Please see https://support.brother.com/g/s/agreement/English_gpl/agree.html. You shall use GPL Modules in accordance with the terms and conditions of GPLv2. Your use of GPL Modules shall be deemed as your agreement to the terms and conditions of GPLv2.

3.You have the right to use all Non-GPL Modules only in accordance with the following terms and conditions. Your use of Non-GPL Modules shall be deemed as your agreement to the following terms and conditions: 
(1) Brother retains any and all copyrights to Non-GPL Modules. In no case this Agreement shall be construed to assign or otherwise transfer from Brother to you any copyrights or other intellectual property rights to whole or any part of Non-GPL Modules.

(2) Brother grants you a non-exclusive license to reproduce and/or distribute (via Internet or in any other manner) Non-GPL Modules. Brother further grants you a non-exclusive license to modify, alter, translate or otherwise prepare derivative works of Non-GPL Modules and to reproduce and/or distribute (via Internet or in any other manner) such modification, alteration, translation or other derivative works of Non-GPL Modules.

(3) When you distribute (via Internet or in any other manner) Non-GPL Modules or any modification, alteration, translation or other derivative works thereof under the license granted in accordance with subparagraph 3(2) above, you must expressly grant any and all recipient thereof the license equivalent to this Agreement which applies to Non-GPL Modules.

(4) The license of Non-GPL Modules from Brother hereunder is granted "AS IS. BROTHER HEREBY DISCLAIMS ANY WARRANTIES WITH RESPECT TO NON-GPL MODULES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTY FOR THE QUALITY, MERCHANTABILITY, FITNESS FOR PARTICULAR PURPOSE OR NON-INFRINGEMENT. 

(5) To the extent allowed by applicable laws, Brother shall have no liability in contract, tort (including negligence or breach of statutory duty) or otherwise for any interruption of use, loss of data, or for any indirect, incidental, punitive or consequential loss or damage, or for any loss of profit, revenue, data, goodwill or anticipated savings that arises under, out of, or in contemplation of this Agreement or otherwise arises due to any error, inaccuracy or defect in Non-GPL Modules even if Brother has been advised of the possibility of such loss or damage.

(6) The form in which Non-GPL Modules is distributed is subject to Brothers sole discretion. Brother does not have any obligation to distribute or disclose Non-GPL Modules in source code form. In no case shall this Agreement be deemed as Brothers express or implied agreement to disclose source code of Non-GPL Modules.
GPLBROTHERLICENSE_U
    fi
}


pdrv_complex_license(){
    echo -e $COLOR2
    if [ $REGION = JPN ];then
	cat <<PDVRLICENSE_J
本契約は、本契約とともに配布・提供されるソフトウェア （以下単に本ソフトウェアといいます） に関し、本ソフトウェアの著作権者であるブラザー工業株式会社 （以下、ブラザーといいます） から本ソフトウェア受領者 （以下単に利用者といいます） に対し与えられる使用許諾について定めるものです。 利用者は、下記条項に従い本ソフトウェアを利用するものとします。 また、利用者は本ソフトウェアを利用することにより、下記条項に同意したものと見なされます。
1.	本ソフトウェアに関する著作権は、ブラザーに帰属します。 本契約は、本ソフトウェアについてブラザーから利用者に対し著作権の全部若しくは一部を譲渡するものとは解され得ません。
2.	ブラザーは利用者に対し、本ソフトウェアについて複製、譲渡 （著作権の譲渡ではなくソフトウェアが格納された媒体の譲渡を指します） および公衆送信を行う権利を無償にて非独占的に許諾します。
3.	さらにブラザーは利用者に対し、いかなる目的のためにでも本ソフトウェアを変更、改変、翻訳あるいは本ソフトウェアの派生物を作成し、かつそれらについて複製、譲渡及び公衆送信を行う権利を無償にて非独占的に許諾します。
4.	ブラザーによる本ソフトウェアの配布・提供は、現状有姿にて行われるものであり、ブラザーは利用者に対し、本ソフトウェアに関し、明示・黙示問わず、何らの保証 （品質保証・有用性に関する保証・特定目的への合致に関する保証その他一切含め） も行いません。
5.	ブラザーは本ソフトウェアに関し、利用者に生じたいかなる損害 （直接損害・間接損害・特別損害・派生損害・懲罰的損害その他一切含め） についても、かかる損害が予測可能か否か、また、その可能性についてブラザーが知っていたか否かを問わず、賠償義務を負いません。
6.	さらにブラザーは利用者に対し、いかなる場合も本ソフトウェアのソースコードを開示する義務を負いません。 上記ブラザーによる変更、改変、翻訳あるいは本ソフトウェアの派生物作成に関するライセンスは、いかなる場合にも、本ソフトウェアのソースコード開示に関するブラザーの黙示的な同意とは解釈されません。
7.	本ソフトウェアには、GNU GENERAL PUBLIC LICENSE Version 2の条件の適用を受けるプログラムが含まれております。第1条から第6項の規定に関わらず、これらのプログラムにはGNU GENERAL PUBLIC LICENSE Version 2の条件が適用されます。これらのプログラムは以下のディレクトリ及びそのサブディレクトリに保存されています。
<cupswrapper>

GNU GENERAL PUBLIC LICENSE
Version 2, June 1991
Copyright (C) 1989, 1991 Free Software Foundation, Inc.  
51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.
Preamble
The licenses for most software are designed to take away your freedom to share and change it. By contrast, the GNU General Public License is intended to guarantee your freedom to share and change free software--to make sure the software is free for all its users. This General Public License applies to most of the Free Software Foundation's software and to any other program whose authors commit to using it. (Some other Free Software Foundation software is covered by the GNU Lesser General Public License instead.) You can apply it to your programs, too.
When we speak of free software, we are referring to freedom, not price. Our General Public Licenses are designed to make sure that you have the freedom to distribute copies of free software (and charge for this service if you wish), that you receive source code or can get it if you want it, that you can change the software or use pieces of it in new free programs; and that you know you can do these things.
To protect your rights, we need to make restrictions that forbid anyone to deny you these rights or to ask you to surrender the rights. These restrictions translate to certain responsibilities for you if you distribute copies of the software, or if you modify it.
For example, if you distribute copies of such a program, whether gratis or for a fee, you must give the recipients all the rights that you have. You must make sure that they, too, receive or can get the source code. And you must show them these terms so they know their rights.
We protect your rights with two steps: (1) copyright the software, and (2) offer you this license which gives you legal permission to copy, distribute and/or modify the software.
Also, for each author's protection and ours, we want to make certain that everyone understands that there is no warranty for this free software. If the software is modified by someone else and passed on, we want its recipients to know that what they have is not the original, so that any problems introduced by others will not reflect on the original authors' reputations.
Finally, any free program is threatened constantly by software patents. We wish to avoid the danger that redistributors of a free program will individually obtain patent licenses, in effect making the program proprietary. To prevent this, we have made it clear that any patent must be licensed for everyone's free use or not licensed at all.
The precise terms and conditions for copying, distribution and modification follow.
TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

0. This License applies to any program or other work which contains a notice placed by the copyright holder saying it may be distributed under the terms of this General Public License. The "Program", below, refers to any such program or work, and a "work based on the Program" means either the Program or any derivative work under copyright law: that is to say, a work containing the Program or a portion of it, either verbatim or with modifications and/or translated into another language. (Hereinafter, translation is included without limitation in the term "modification".) Each licensee is addressed as "you".
Activities other than copying, distribution and modification are not covered by this License; they are outside its scope. The act of running the Program is not restricted, and the output from the Program is covered only if its contents constitute a work based on the Program (independent of having been made by running the Program). Whether that is true depends on what the Program does.

1. You may copy and distribute verbatim copies of the Program's source code as you receive it, in any medium, provided that you conspicuously and appropriately publish on each copy an appropriate copyright notice and disclaimer of warranty; keep intact all the notices that refer to this License and to the absence of any warranty; and give any other recipients of the Program a copy of this License along with the Program.
You may charge a fee for the physical act of transferring a copy, and you may at your option offer warranty protection in exchange for a fee.

2. You may modify your copy or copies of the Program or any portion of it, thus forming a work based on the Program, and copy and distribute such modifications or work under the terms of Section 1 above, provided that you also meet all of these conditions:

a) You must cause the modified files to carry prominent notices stating that you changed the files and the date of any change.

b) You must cause any work that you distribute or publish, that in whole or in part contains or is derived from the Program or any part thereof, to be licensed as a whole at no charge to all third parties under the terms of this License.

c) If the modified program normally reads commands interactively when run, you must cause it, when started running for such interactive use in the most ordinary way, to print or display an announcement including an appropriate copyright notice and a notice that there is no warranty (or else, saying that you provide a warranty) and that users may redistribute the program under these conditions, and telling the user how to view a copy of this License. (Exception: if the Program itself is interactive but does not normally print such an announcement, your work based on the Program is not required to print an announcement.)
These requirements apply to the modified work as a whole. If identifiable sections of that work are not derived from the Program, and can be reasonably considered independent and separate works in themselves, then this License, and its terms, do not apply to those sections when you distribute them as separate works. But when you distribute the same sections as part of a whole which is a work based on the Program, the distribution of the whole must be on the terms of this License, whose permissions for other licensees extend to the entire whole, and thus to each and every part regardless of who wrote it.
Thus, it is not the intent of this section to claim rights or contest your rights to work written entirely by you; rather, the intent is to exercise the right to control the distribution of derivative or collective works based on the Program.
In addition, mere aggregation of another work not based on the Program with the Program (or with a work based on the Program) on a volume of a storage or distribution medium does not bring the other work under the scope of this License.

3. You may copy and distribute the Program (or a work based on it, under Section 2) in object code or executable form under the terms of Sections 1 and 2 above provided that you also do one of the following:

a) Accompany it with the complete corresponding machine-readable source code, which must be distributed under the terms of Sections 1 and 2 above on a medium customarily used for software interchange; or,

b) Accompany it with a written offer, valid for at least three years, to give any third party, for a charge no more than your cost of physically performing source distribution, a complete machine-readable copy of the corresponding source code, to be distributed under the terms of Sections 1 and 2 above on a medium customarily used for software interchange; or,

c) Accompany it with the information you received as to the offer to distribute corresponding source code. (This alternative is allowed only for noncommercial distribution and only if you received the program in object code or executable form with such an offer, in accord with Subsection b above.)
The source code for a work means the preferred form of the work for making modifications to it. For an executable work, complete source code means all the source code for all modules it contains, plus any associated interface definition files, plus the scripts used to control compilation and installation of the executable. However, as a special exception, the source code distributed need not include anything that is normally distributed (in either source or binary form) with the major components (compiler, kernel, and so on) of the operating system on which the executable runs, unless that component itself accompanies the executable.
If distribution of executable or object code is made by offering access to copy from a designated place, then offering equivalent access to copy the source code from the same place counts as distribution of the source code, even though third parties are not compelled to copy the source along with the object code.

4. You may not copy, modify, sublicense, or distribute the Program except as expressly provided under this License. Any attempt otherwise to copy, modify, sublicense or distribute the Program is void, and will automatically terminate your rights under this License. However, parties who have received copies, or rights, from you under this License will not have their licenses terminated so long as such parties remain in full compliance.

5. You are not required to accept this License, since you have not signed it. However, nothing else grants you permission to modify or distribute the Program or its derivative works. These actions are prohibited by law if you do not accept this License. Therefore, by modifying or distributing the Program (or any work based on the Program), you indicate your acceptance of this License to do so, and all its terms and conditions for copying, distributing or modifying the Program or works based on it.

6. Each time you redistribute the Program (or any work based on the Program), the recipient automatically receives a license from the original licensor to copy, distribute or modify the Program subject to these terms and conditions. You may not impose any further restrictions on the recipients' exercise of the rights granted herein. You are not responsible for enforcing compliance by third parties to this License.

7. If, as a consequence of a court judgment or allegation of patent infringement or for any other reason (not limited to patent issues), conditions are imposed on you (whether by court order, agreement or otherwise) that contradict the conditions of this License, they do not excuse you from the conditions of this License. If you cannot distribute so as to satisfy simultaneously your obligations under this License and any other pertinent obligations, then as a consequence you may not distribute the Program at all. For example, if a patent license would not permit royalty-free redistribution of the Program by all those who receive copies directly or indirectly through you, then the only way you could satisfy both it and this License would be to refrain entirely from distribution of the Program.
If any portion of this section is held invalid or unenforceable under any particular circumstance, the balance of the section is intended to apply and the section as a whole is intended to apply in other circumstances.
It is not the purpose of this section to induce you to infringe any patents or other property right claims or to contest validity of any such claims; this section has the sole purpose of protecting the integrity of the free software distribution system, which is implemented by public license practices. Many people have made generous contributions to the wide range of software distributed through that system in reliance on consistent application of that system; it is up to the author/donor to decide if he or she is willing to distribute software through any other system and a licensee cannot impose that choice.
This section is intended to make thoroughly clear what is believed to be a consequence of the rest of this License.

8. If the distribution and/or use of the Program is restricted in certain countries either by patents or by copyrighted interfaces, the original copyright holder who places the Program under this License may add an explicit geographical distribution limitation excluding those countries, so that distribution is permitted only in or among countries not thus excluded. In such case, this License incorporates the limitation as if written in the body of this License.

9. The Free Software Foundation may publish revised and/or new versions of the General Public License from time to time. Such new versions will be similar in spirit to the present version, but may differ in detail to address new problems or concerns.
Each version is given a distinguishing version number. If the Program specifies a version number of this License which applies to it and "any later version", you have the option of following the terms and conditions either of that version or of any later version published by the Free Software Foundation. If the Program does not specify a version number of this License, you may choose any version ever published by the Free Software Foundation.

10. If you wish to incorporate parts of the Program into other free programs whose distribution conditions are different, write to the author to ask for permission. For software which is copyrighted by the Free Software Foundation, write to the Free Software Foundation; we sometimes make exceptions for this. Our decision will be guided by the two goals of preserving the free status of all derivatives of our free software and of promoting the sharing and reuse of software generally.

NO WARRANTY
11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
END OF TERMS AND CONDITIONS
How to Apply These Terms to Your New Programs
If you develop a new program, and you want it to be of the greatest possible use to the public, the best way to achieve this is to make it free software which everyone can redistribute and change under these terms.
To do so, attach the following notices to the program. It is safest to attach them to the start of each source file to most effectively convey the exclusion of warranty; and each file should have at least the "copyright" line and a pointer to where the full notice is found.
one line to give the program's name and an idea of what it does.
Copyright (C) yyyy  name of author

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
Also add information on how to contact you by electronic and paper mail.
If the program is interactive, make it output a short notice like this when it starts in an interactive mode:
Gnomovision version 69, Copyright (C) year name of author
Gnomovision comes with ABSOLUTELY NO WARRANTY; for details
type \`show w'.  This is free software, and you are welcome
to redistribute it under certain conditions; type \`show c' 
for details.
The hypothetical commands \`show w' and \`show c' should show the appropriate parts of the General Public License. Of course, the commands you use may be called something other than \`show w' and \`show c'; they could even be mouse-clicks or menu items--whatever suits your program.
You should also get your employer (if you work as a programmer) or your school, if any, to sign a "copyright disclaimer" for the program, if necessary. Here is a sample; alter the names:
Yoyodyne, Inc., hereby disclaims all copyright interest in the program \`Gnomovision' (which makes passes at compilers) written by James Hacker.

signature of Ty Coon, 1 April 1989
Ty Coon, President of Vice
This General Public License does not permit incorporating your program into proprietary programs. If your program is a subroutine library, you may consider it more useful to permit linking proprietary applications with the library. If this is what you want to do, use the GNU Lesser General Public License instead of this License.

PDVRLICENSE_J
    else 
	cat <<PDVRLICENSE_U
License Agreement

This Agreement provides terms and conditions for license grant from Brother Industries, Ltd ("Brother"). Brother, who owns all copyrights to the software that is distributed with this Agreement ("Software") to recipients thereof ("User"), for use of the Software. User shall have the right to use the Software only in accordance with the terms and conditions of this Agreement. Any use by User of the Software shall be deemed as its agreement hereto.
Note:
Please click on "I Accept" while holding down "Shift" or right click on "I Accept" and select "Save Target As,,," from the menu.


Brother retains any and all copyrights to the Software. In no case this Agreement shall be construed to assign or otherwise transfer from Brother to User any copyrights or other intellectual property rights to whole or any part of the Software.
Brother grants User a non-exclusive license: to reproduce and/or distribute (via Internet or in any other manner) the Software. Further, Brother grants User a non-exclusive license to modify, alter, translate or otherwise prepare derivative works of the Software and to reproduce and distribute (via Internet or in any other manner) such modification, alteration, translation or other derivative works for any purpose.
The license of the Software from Brother hereunder is granted "AS IS." BROTHER HEREBY DISCLAIMS ANY WARRANTIES WITH RESPECT TO THE SOFTWARE, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTY FOR THE QUALITY, MERCHANTABILITY, FITNESS FOR PARTICULAR PURPOSE OR NON-INFRINGEMENT. Brother shall have no liability in contract, tort (including negligence or breach of statutory duty) or otherwise for any interruption of use, loss of data, or for any indirect, incidental, punitive or consequential loss or damage, or for any loss of profit, revenue, data, goodwill or anticipated savings that arises under, out of, or in contemplation of this Agreement or otherwise arises due to any error, inaccuracy or defect in the Software even if Brother has been advised of the possibility of such loss or damage. Further, Brother shall have no liability to disclose and/or distribute the source code of the Software to User under any circumstances. In no case shall the above license by Brother to modify, alter, translate or otherwise prepare derivative works of the Software be construed as Brother's implied agreement or undertakings to disclose and/or distribute the source code of the Software.
The Software contains the programs licensed under the terms and conditions of GNU GENERAL PUBLIC LICENSE Version 2. Notwithstanding the foregoing, the terms and conditions of GNU GENERAL PUBLIC LICENSE Version 2 is applied to such programs. Such programs are stored on the following directory and its sub-directories.
<cupswrapper>
GNU GENERAL PUBLIC LICENSE
Version 2, June 1991
Copyright (C) 1989, 1991 Free Software Foundation, Inc.  
51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.
Preamble
The licenses for most software are designed to take away your freedom to share and change it. By contrast, the GNU General Public License is intended to guarantee your freedom to share and change free software--to make sure the software is free for all its users. This General Public License applies to most of the Free Software Foundation's software and to any other program whose authors commit to using it. (Some other Free Software Foundation software is covered by the GNU Lesser General Public License instead.) You can apply it to your programs, too.
When we speak of free software, we are referring to freedom, not price. Our General Public Licenses are designed to make sure that you have the freedom to distribute copies of free software (and charge for this service if you wish), that you receive source code or can get it if you want it, that you can change the software or use pieces of it in new free programs; and that you know you can do these things.
To protect your rights, we need to make restrictions that forbid anyone to deny you these rights or to ask you to surrender the rights. These restrictions translate to certain responsibilities for you if you distribute copies of the software, or if you modify it.
For example, if you distribute copies of such a program, whether gratis or for a fee, you must give the recipients all the rights that you have. You must make sure that they, too, receive or can get the source code. And you must show them these terms so they know their rights.
We protect your rights with two steps: (1) copyright the software, and (2) offer you this license which gives you legal permission to copy, distribute and/or modify the software.
Also, for each author's protection and ours, we want to make certain that everyone understands that there is no warranty for this free software. If the software is modified by someone else and passed on, we want its recipients to know that what they have is not the original, so that any problems introduced by others will not reflect on the original authors' reputations.
Finally, any free program is threatened constantly by software patents. We wish to avoid the danger that redistributors of a free program will individually obtain patent licenses, in effect making the program proprietary. To prevent this, we have made it clear that any patent must be licensed for everyone's free use or not licensed at all.
The precise terms and conditions for copying, distribution and modification follow.
TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

0. This License applies to any program or other work which contains a notice placed by the copyright holder saying it may be distributed under the terms of this General Public License. The "Program", below, refers to any such program or work, and a "work based on the Program" means either the Program or any derivative work under copyright law: that is to say, a work containing the Program or a portion of it, either verbatim or with modifications and/or translated into another language. (Hereinafter, translation is included without limitation in the term "modification".) Each licensee is addressed as "you".
Activities other than copying, distribution and modification are not covered by this License; they are outside its scope. The act of running the Program is not restricted, and the output from the Program is covered only if its contents constitute a work based on the Program (independent of having been made by running the Program). Whether that is true depends on what the Program does.

1. You may copy and distribute verbatim copies of the Program's source code as you receive it, in any medium, provided that you conspicuously and appropriately publish on each copy an appropriate copyright notice and disclaimer of warranty; keep intact all the notices that refer to this License and to the absence of any warranty; and give any other recipients of the Program a copy of this License along with the Program.
You may charge a fee for the physical act of transferring a copy, and you may at your option offer warranty protection in exchange for a fee.

2. You may modify your copy or copies of the Program or any portion of it, thus forming a work based on the Program, and copy and distribute such modifications or work under the terms of Section 1 above, provided that you also meet all of these conditions:

a) You must cause the modified files to carry prominent notices stating that you changed the files and the date of any change.

b) You must cause any work that you distribute or publish, that in whole or in part contains or is derived from the Program or any part thereof, to be licensed as a whole at no charge to all third parties under the terms of this License.

c) If the modified program normally reads commands interactively when run, you must cause it, when started running for such interactive use in the most ordinary way, to print or display an announcement including an appropriate copyright notice and a notice that there is no warranty (or else, saying that you provide a warranty) and that users may redistribute the program under these conditions, and telling the user how to view a copy of this License. (Exception: if the Program itself is interactive but does not normally print such an announcement, your work based on the Program is not required to print an announcement.)
These requirements apply to the modified work as a whole. If identifiable sections of that work are not derived from the Program, and can be reasonably considered independent and separate works in themselves, then this License, and its terms, do not apply to those sections when you distribute them as separate works. But when you distribute the same sections as part of a whole which is a work based on the Program, the distribution of the whole must be on the terms of this License, whose permissions for other licensees extend to the entire whole, and thus to each and every part regardless of who wrote it.
Thus, it is not the intent of this section to claim rights or contest your rights to work written entirely by you; rather, the intent is to exercise the right to control the distribution of derivative or collective works based on the Program.
In addition, mere aggregation of another work not based on the Program with the Program (or with a work based on the Program) on a volume of a storage or distribution medium does not bring the other work under the scope of this License.

3. You may copy and distribute the Program (or a work based on it, under Section 2) in object code or executable form under the terms of Sections 1 and 2 above provided that you also do one of the following:

a) Accompany it with the complete corresponding machine-readable source code, which must be distributed under the terms of Sections 1 and 2 above on a medium customarily used for software interchange; or,

b) Accompany it with a written offer, valid for at least three years, to give any third party, for a charge no more than your cost of physically performing source distribution, a complete machine-readable copy of the corresponding source code, to be distributed under the terms of Sections 1 and 2 above on a medium customarily used for software interchange; or,

c) Accompany it with the information you received as to the offer to distribute corresponding source code. (This alternative is allowed only for noncommercial distribution and only if you received the program in object code or executable form with such an offer, in accord with Subsection b above.)
The source code for a work means the preferred form of the work for making modifications to it. For an executable work, complete source code means all the source code for all modules it contains, plus any associated interface definition files, plus the scripts used to control compilation and installation of the executable. However, as a special exception, the source code distributed need not include anything that is normally distributed (in either source or binary form) with the major components (compiler, kernel, and so on) of the operating system on which the executable runs, unless that component itself accompanies the executable.
If distribution of executable or object code is made by offering access to copy from a designated place, then offering equivalent access to copy the source code from the same place counts as distribution of the source code, even though third parties are not compelled to copy the source along with the object code.

4. You may not copy, modify, sublicense, or distribute the Program except as expressly provided under this License. Any attempt otherwise to copy, modify, sublicense or distribute the Program is void, and will automatically terminate your rights under this License. However, parties who have received copies, or rights, from you under this License will not have their licenses terminated so long as such parties remain in full compliance.

5. You are not required to accept this License, since you have not signed it. However, nothing else grants you permission to modify or distribute the Program or its derivative works. These actions are prohibited by law if you do not accept this License. Therefore, by modifying or distributing the Program (or any work based on the Program), you indicate your acceptance of this License to do so, and all its terms and conditions for copying, distributing or modifying the Program or works based on it.

6. Each time you redistribute the Program (or any work based on the Program), the recipient automatically receives a license from the original licensor to copy, distribute or modify the Program subject to these terms and conditions. You may not impose any further restrictions on the recipients' exercise of the rights granted herein. You are not responsible for enforcing compliance by third parties to this License.

7. If, as a consequence of a court judgment or allegation of patent infringement or for any other reason (not limited to patent issues), conditions are imposed on you (whether by court order, agreement or otherwise) that contradict the conditions of this License, they do not excuse you from the conditions of this License. If you cannot distribute so as to satisfy simultaneously your obligations under this License and any other pertinent obligations, then as a consequence you may not distribute the Program at all. For example, if a patent license would not permit royalty-free redistribution of the Program by all those who receive copies directly or indirectly through you, then the only way you could satisfy both it and this License would be to refrain entirely from distribution of the Program.
If any portion of this section is held invalid or unenforceable under any particular circumstance, the balance of the section is intended to apply and the section as a whole is intended to apply in other circumstances.
It is not the purpose of this section to induce you to infringe any patents or other property right claims or to contest validity of any such claims; this section has the sole purpose of protecting the integrity of the free software distribution system, which is implemented by public license practices. Many people have made generous contributions to the wide range of software distributed through that system in reliance on consistent application of that system; it is up to the author/donor to decide if he or she is willing to distribute software through any other system and a licensee cannot impose that choice.
This section is intended to make thoroughly clear what is believed to be a consequence of the rest of this License.

8. If the distribution and/or use of the Program is restricted in certain countries either by patents or by copyrighted interfaces, the original copyright holder who places the Program under this License may add an explicit geographical distribution limitation excluding those countries, so that distribution is permitted only in or among countries not thus excluded. In such case, this License incorporates the limitation as if written in the body of this License.

9. The Free Software Foundation may publish revised and/or new versions of the General Public License from time to time. Such new versions will be similar in spirit to the present version, but may differ in detail to address new problems or concerns.
Each version is given a distinguishing version number. If the Program specifies a version number of this License which applies to it and "any later version", you have the option of following the terms and conditions either of that version or of any later version published by the Free Software Foundation. If the Program does not specify a version number of this License, you may choose any version ever published by the Free Software Foundation.

10. If you wish to incorporate parts of the Program into other free programs whose distribution conditions are different, write to the author to ask for permission. For software which is copyrighted by the Free Software Foundation, write to the Free Software Foundation; we sometimes make exceptions for this. Our decision will be guided by the two goals of preserving the free status of all derivatives of our free software and of promoting the sharing and reuse of software generally.

NO WARRANTY
11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
END OF TERMS AND CONDITIONS
How to Apply These Terms to Your New Programs
If you develop a new program, and you want it to be of the greatest possible use to the public, the best way to achieve this is to make it free software which everyone can redistribute and change under these terms.
To do so, attach the following notices to the program. It is safest to attach them to the start of each source file to most effectively convey the exclusion of warranty; and each file should have at least the "copyright" line and a pointer to where the full notice is found.
one line to give the program's name and an idea of what it does.
Copyright (C) yyyy  name of author

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
Also add information on how to contact you by electronic and paper mail.
If the program is interactive, make it output a short notice like this when it starts in an interactive mode:
Gnomovision version 69, Copyright (C) year name of author
Gnomovision comes with ABSOLUTELY NO WARRANTY; for details
type \`show w'.  This is free software, and you are welcome
to redistribute it under certain conditions; type \`show c' 
for details.
The hypothetical commands \`show w' and \`show c' should show the appropriate parts of the General Public License. Of course, the commands you use may be called something other than \`show w' and \`show c'; they could even be mouse-clicks or menu items--whatever suits your program.
You should also get your employer (if you work as a programmer) or your school, if any, to sign a "copyright disclaimer" for the program, if necessary. Here is a sample; alter the names:
Yoyodyne, Inc., hereby disclaims all copyright interest in the program \`Gnomovision' (which makes passes at compilers) written by James Hacker.

signature of Ty Coon, 1 April 1989
Ty Coon, President of Vice
This General Public License does not permit incorporating your program into proprietary programs. If your program is a subroutine library, you may consider it more useful to permit linking proprietary applications with the library. If this is what you want to do, use the GNU Lesser General Public License instead of this License.


PDVRLICENSE_U
    fi
    
}



TIMEOUT=30


WGET_OP="-T 10 -nd "
WGET_OP2="-nd -T 10 -t 1 "

DBG_MSG(){
  if [ "$DEBUG_MSG" = 1 ];then
     echo -e ${COLOR3}"DEBUGMSG : $1"${MONO}
  fi
}

MESSAGE(){
  if [ "$MSG" = 1 ];then
     echo -e ${COLOR3}"$1"${MONO}
  fi
}

install_done=no
preproc_done=''
postproc_done=''
PREPROC=''
POSTPROC=''

pre_install_sweep(){
  DBG_MSG pre_install_sweep
  ORGC="/etc/init.d/cups"
  ORGL="/etc/init.d/lpd"
  ORGLN="/etc/init.d/lprng"
  SYMLNC="cups -> /etc/init.d/cupsys"
  SYMLNL="lpd -> /etc/init.d/cupsys"
  SYMLNLN="lprng -> /etc/init.d/cupsys"
  
  if [ "$(ls -al $ORGC  2> /dev/null | grep ^l | grep "$SYMLNC" )" != '' ] 
  then 
    rm -f $ORGC   2> /dev/null
  fi
  if [ "$(ls -al $ORGL  2> /dev/null | grep ^l | grep "$SYMLNL" )" != '' ]
  then 
    rm -f $ORGL   2> /dev/null
  fi
  if [ "$(ls -al $ORGLN  2> /dev/null | grep ^l | grep "$SYMLNLN")" != '' ]
  then 
    rm -f $ORGLN   2> /dev/null
  fi
}

post_install_sweep(){
  DBG_MSG post_install_sweep
    if [ ! -d ${wkdir}/${modelnhuc} ];then
      if [ -f ${wkdir}/${modelnhuc} ];then
         rm -f  ${wkdir}/${modelnhuc}   2> /dev/null
      fi
    fi
}


#
#  get inf file
#    chaged values :
#      ${modelnhuc}
#      ${fulpath}
#
get_inf_file(){
  SUFFIX1="N C D DN DW DWN DWT CN CW CDN CD CDW CDWT DNLT JN J CLN CLWN WR"
  DBG_MSG get_inf_file

  if [ $NODOWNLOAD = 1 ];then
    cp  $INFPATH  ${wkdir}
    modelnhuc=$MODEL
  elif [ $NODOWNLOAD = 2 ];then
    modelnhuc=$MODEL
  else

    inputmodel=$1
    modelnhuc=$(echo $inputmodel | tr "[a-z]" "[A-Z]" | tr -d '-')

    if [ "${modelnhuc}" = '' ];then
      echo ERROR :$inputmodel , $1   ,  ${modelnhuc}
      #DBG_MSG  "exit 1"
      rmdir "${wkdir}"
      exit 0
    fi

    fulpath=$URL_INF/${modelnhuc}

    dlresult=IDENTIC
    if [ $infcheck = 0 ] && [ $HIDE_INF = NO ];then
      MESSAGE  "wget $WGET_OP $CACHEFLG -P ${wkdir} $fulpath"
    fi
  fi
  wget $WGET_OP $CACHEFLG -P ${wkdir} $fulpath    > /dev/null 2> /dev/null 

  #--------------------------------------   
  
  if [ ! -f ${wkdir}/${modelnhuc} ];then
     #     DCP315C -> DCP315CN
     dlresult=APPROX1
     modelnhuc2=$(echo $inputmodel | tr "[a-z]" "[A-Z]" | tr -d '-' |\
		sed -e s/"[A-Z][A-Z][A-Z][A-Z]$"/""/g         \
		    -e s/"[A-Z][A-Z][A-Z]$"/""/g              \
		    -e s/"[A-Z][A-Z]$"/""/g                   \
                    -e s/"[A-Z]$"/""/g )

     for suffix in $SUFFIX1
     do
       modelnhuc=${modelnhuc2}${suffix}

       if [ "${modelnhuc}" != '' ];then
         fulpath=$URL_INF/${modelnhuc}
         if [ $infcheck = 0 ] && [ $HIDE_INF = NO ];then 
	   MESSAGE "wget $WGET_OP $CACHEFLG -P ${wkdir} $fulpath"
	 fi
	 wget $WGET_OP $CACHEFLG -P ${wkdir} $fulpath > /dev/null 2> /dev/null 
         if [ $? = '0' ];then 
           break
         fi
       fi  
       modelnhuc='___not_found___'
     done
  fi

  #--------------------------------------   
  if [ ! -f ${wkdir}/${modelnhuc} ];then
    #  DCP315C  -> DCP315
    dlresult=APPROX2
    modelnhuc=$(echo $inputmodel | tr "[a-z]" "[A-Z]" | tr -d '-' |\
		sed -e s/"[A-Z][A-Z][A-Z][A-Z]$"/""/g         \
		    -e s/"[A-Z][A-Z][A-Z]$"/""/g              \
		    -e s/"[A-Z][A-Z]$"/""/g                   \
                    -e s/"[A-Z]$"/""/g )

		    
    if [ "${modelnhuc}" != '' ];then
      fulpath=$URL_INF/${modelnhuc}
      if [ $infcheck = 0 ] && [ $HIDE_INF = NO ];then
	MESSAGE "wget $WGET_OP $CACHEFLG -P ${wkdir} $fulpath"
      fi
      wget $WGET_OP $CACHEFLG -P ${wkdir} $fulpath     > /dev/null 2> /dev/null 
    fi
  fi

  #--------------------------------------   
  if [ ! -f "${wkdir}/${modelnhuc}" ];then
    #    DCP315C   -> DCP310C   
    dlresult=APPROX3
    modelnhuc=$(echo $inputmodel | \
		sed -e s/"[0-9]$"/"0"/g  \
		    -e s/"[0-9]C"/"0C"/g \
		    -e s/"[0-9]D"/"0D"/g \
		    -e s/"[0-9]W"/"0W"/g \
		    -e s/"[0-9]N"/"0N"/g )
    if [ "${modelnhuc}" != '' ];then
      fulpath=$URL_INF/${modelnhuc}
      #echo wget $WGET_OP $CACHEFLG -P ${wkdir} $fulpath
      if [ $infcheck = 0 ] && [ $HIDE_INF = NO ];then 
        MESSAGE "wget $WGET_OP $CACHEFLG -P ${wkdir} $fulpath"
      fi
      wget $WGET_OP $CACHEFLG -P ${wkdir} $fulpath     > /dev/null 2> /dev/null 
    fi
  fi
  #--------------------------------------   

  if [ ! -f ${wkdir}/${modelnhuc} ];then
    #    DCP315C   -> DCP310CN
    dlresult=APPROX4
    modelnhuc2=$(echo $inputmodel | tr "[a-z]" "[A-Z]" | tr -d '-' |\
		sed -e s/"[A-Z][A-Z][A-Z][A-Z]$"/""/g         \
		    -e s/"[A-Z][A-Z][A-Z]$"/""/g              \
		    -e s/"[A-Z][A-Z]$"/""/g                   \
                    -e s/"[A-Z]$"/""/g                       |\
                sed s/"[0-9]$"/"0"/g )

    for suffix in $SUFFIX1
    do
       modelnhuc=${modelnhuc2}${suffix}
       if [ "${modelnhuc}" != '' ];then
         fulpath=$URL_INF/${modelnhuc}
         if [ $infcheck = 0 ] && [ $HIDE_INF = NO ];then 
	   MESSAGE "wget $WGET_OP $CACHEFLG -P ${wkdir} $fulpath"
	 fi
	 wget $WGET_OP $CACHEFLG -P ${wkdir} $fulpath > /dev/null 2> /dev/null 
         if [ $? = '0' ];then 
           break
         fi
       fi  
       modelnhuc='___not_found___'
    done 
  fi

  #--------------------------------------   

  if [ ! -f ${wkdir}/${modelnhuc} ];then
    #    DCP315C   -> DCP310
    dlresult=APPROX5
    modelnhuc=$(echo $inputmodel | tr "[a-z]" "[A-Z]" | tr -d '-' |\
		sed -e s/"[A-Z][A-Z][A-Z][A-Z]$"/""/g         \
		    -e s/"[A-Z][A-Z][A-Z]$"/""/g              \
		    -e s/"[A-Z][A-Z]$"/""/g                   \
                    -e s/"[A-Z]$"/""/g                       |\
                sed s/"[0-9]$"/"0"/g )

    if [ "${modelnhuc}" != '' ];then
      fulpath=$URL_INF/${modelnhuc}
      if [ $infcheck = 0 ] && [ $HIDE_INF = NO ];then 
	MESSAGE "wget $WGET_OP $CACHEFLG -P ${wkdir} $fulpath"
      fi
      wget $WGET_OP $CACHEFLG -P ${wkdir} $fulpath > /dev/null 2> /dev/null 
    fi
    if [ ! -f ${wkdir}/${modelnhuc} ];then
       modelnhuc='___not_found___'

    fi
  fi

  #--------------------------------------   




  if [ -f ${wkdir}/${modelnhuc} ];then

    lnk=$(grep "LNK=" ${wkdir}/${modelnhuc} 2>/dev/null | sed s/'LNK='//g)
    if [ "$lnk" != '' ];then
      PRODUCT_NAME=$(grep "^\[" ${wkdir}/${modelnhuc} 2>/dev/null | sed -e s/"\["//g -e s/"\]"//g) 

      PREPROC=$(grep "PREPROC=" ${wkdir}/${modelnhuc} 2>/dev/null | \
                    sed s/"PREPROC="//g | \
                    sed -e s/^\"//g -e s/\"$//g )
      POSTPROC=$(grep "POSTPROC=" ${wkdir}/${modelnhuc} 2>/dev/null | \
                    sed s/"POSTPROC="//g | \
                    sed -e s/^\"//g -e s/\"$//g )
      lnk_flag="LINK"
      LNK_PRINTERNAME=$(grep "PRINTERNAME" ${wkdir}/${modelnhuc} \
	  2>/dev/null | sed s/"PRINTERNAME="//g )
      if [ -f ${wkdir}/${modelnhuc} ];then
         rm -f  ${wkdir}/${modelnhuc}   2> /dev/null
      fi

      modelnhuc=${lnk}
      fulpath=$URL_INF/${modelnhuc}
      if [ $infcheck = 0 ] && [ $HIDE_INF = NO ];then 
        MESSAGE "wget $WGET_OP $CACHEFLG -P ${wkdir} $fulpath"
      fi
      wget $WGET_OP $CACHEFLG -P ${wkdir} $fulpath  > /dev/null 2> /dev/null 
    fi
  fi

  if [ "$modelnhuc" = '___not_found___' ];then
     modelnhuc=''
  fi

}



get_packages_name(){
  DBG_MSG get_packages_name
  inf=${wkdir}/$1
  if [ "$PRODUCT_NAME" = '' ];then
    PRODUCT_NAME=$(grep "\[" $inf 2>/dev/null | sed -e s/"\["//g -e s/"\]"//g) 
  fi
  SCANNER_DRV=$(grep "SCANNER_DRV" $inf 2>/dev/null | sed s/"SCANNER_DRV="//g )
  SCANKEY_DRV=$(grep "SCANKEY_DRV" $inf 2>/dev/null | sed s/"SCANKEY_DRV="//g )
  PRINTERNAME=$(grep "PRINTERNAME" $inf 2>/dev/null | sed s/"PRINTERNAME="//g )
  if [ "$SCANNER_DRV" != '' ];then
     SCANNER_LNK="$SCANNER_DRV".lnk
     fulpath=$URL_INF/$SCANNER_LNK
     

     if [ $infcheck = 0 ] && [ $HIDE_INF = NO ];then
	echo wget  $WGET_OP $CACHEFLG -P ${wkdir} $fulpath 
     fi
     wget  $WGET_OP $CACHEFLG -P ${wkdir} $fulpath 2> /dev/null
  fi
  if [ "$SCANKEY_DRV" != '' ];then
     SCANKEY_LNK="$SCANKEY_DRV".lnk
     fulpath=$URL_INF/$SCANKEY_LNK
     if [ $infcheck = 0 ] && [ $HIDE_INF = NO ];then
     	echo wget  $WGET_OP $CACHEFLG -P ${wkdir} $fulpath 
     fi
     wget  $WGET_OP $CACHEFLG -P ${wkdir} $fulpath  2> /dev/null
  fi

  if [ "$PKG" = rpm ];then
    CUPSFILE=$(grep "PRN_CUP_RPM" $inf 2>/dev/null | sed s/"PRN_CUP_RPM="//g )
    LPRFILE=$(grep "PRN_LPD_RPM" $inf  2>/dev/null | sed s/"PRN_LPD_RPM="//g )
    PDRVFILE=$(grep "PRN_DRV_RPM" $inf  2>/dev/null | sed s/"PRN_DRV_RPM="//g )
    REQ32LIB=$(grep "REQUIRE32LIB" $inf  2>/dev/null| sed s/"REQUIRE32LIB="//g )
    if [ "$SCANNER_LNK" != '' ];then
      if [ "$arch" = 'i386' ];then
        SCANFILE=$(grep "RPM32=" ${wkdir}/"$SCANNER_LNK" | sed s/"RPM32="//g )
      else
        SCANFILE=$(grep "RPM64=" ${wkdir}/"$SCANNER_LNK" | sed s/"RPM64="//g )
      fi
    fi
    if [ "$SCANKEY_LNK" != '' ];then
      if [ "$arch" = 'i386' ];then
        SKEYFILE=$(grep "RPM32=" ${wkdir}/"$SCANKEY_LNK" | sed s/"RPM32="//g )
      else
        SKEYFILE=$(grep "RPM64=" ${wkdir}/"$SCANKEY_LNK" | sed s/"RPM64="//g )
      fi
    fi


  else
    CUPSFILE=$(grep "PRN_CUP_DEB" $inf 2>/dev/null | sed s/"PRN_CUP_DEB="//g )
    LPRFILE=$(grep "PRN_LPD_DEB" $inf  2>/dev/null | sed s/"PRN_LPD_DEB="//g )
    PDRVFILE=$(grep "PRN_DRV_DEB" $inf  2>/dev/null | sed s/"PRN_DRV_DEB="//g )
    REQ32LIB=$(grep "REQUIRE32LIB" $inf  2>/dev/null| sed s/"REQUIRE32LIB="//g )
    if [ "$SCANNER_LNK" != '' ];then
      if [ "$arch" = 'i386' ];then
        SCANFILE=$(grep "DEB32=" ${wkdir}/"$SCANNER_LNK" | sed s/"DEB32="//g )
      else
        SCANFILE=$(grep "DEB64=" ${wkdir}/"$SCANNER_LNK" | sed s/"DEB64="//g )
      fi
    fi
    if [ "$SCANKEY_LNK" != '' ];then
      if [ "$arch" = 'i386' ];then
        SKEYFILE=$(grep "DEB32=" ${wkdir}/"$SCANKEY_LNK" | sed s/"DEB32="//g )
      else
        SKEYFILE=$(grep "DEB64=" ${wkdir}/"$SCANKEY_LNK" | sed s/"DEB64="//g )
      fi
    fi

  fi

  if [ "$PREPROC" = '' ];then
    PREPROC=$(grep "PREPROC=" $inf 2>/dev/null | \
                    sed s/"PREPROC="//g | \
                    sed -e s/^\"//g -e s/\"$//g )
  fi
  if [ "$POSTPROC" = '' ];then
    POSTPROC=$(grep "POSTPROC=" $inf 2>/dev/null | \
                    sed s/"POSTPROC="//g | \
                    sed -e s/^\"//g -e s/\"$//g )

  fi

  if [ -f "$inf" ];then
    rm -f "$inf"   2> /dev/null
  fi
  if [ -f ${wkdir}/"$SCANNER_LNK" ] && [ "$SCANNER_LNK" != '' ];then
    rm -f ${wkdir}/"$SCANNER_LNK"   2> /dev/null
  fi
  if [ -f ${wkdir}/"$SCANKEY_LNK" ] && [ "$SCANKEY_LNK" != '' ];then
    rm -f ${wkdir}/"$SCANKEY_LNK"   2> /dev/null
  fi
}

HOSTDEFAULT="download.brother.com"
HOSTINFJP=$HOSTDEFAULT
HOSTINFUS=$HOSTDEFAULT
HOSTPKGJP=$HOSTDEFAULT
HOSTPKGUS=$HOSTDEFAULT

DBG_MSG  BROTHERSOLUTIONSCENTOR_HOSTINFJP=$BROTHERSOLUTIONSCENTOR_HOSTINFJP
DBG_MSG  BROTHERSOLUTIONSCENTOR_HOSTINFUS=$BROTHERSOLUTIONSCENTOR_HOSTINFUS
DBG_MSG  BROTHERSOLUTIONSCENTOR_HOSTPKGJP=$BROTHERSOLUTIONSCENTOR_HOSTPKGJP
DBG_MSG  BROTHERSOLUTIONSCENTOR_HOSTPKGUS=$BROTHERSOLUTIONSCENTOR_HOSTPKGUS

if [ "$BROTHERSOLUTIONSCENTOR_HOSTINFJP" != '' ];then
   HOSTINFJP=$BROTHERSOLUTIONSCENTOR_HOSTINFJP
fi

if [ "$BROTHERSOLUTIONSCENTOR_HOSTINFUS" != '' ];then
   HOSTINFUS=$BROTHERSOLUTIONSCENTOR_HOSTINFUS
fi

if [ "$BROTHERSOLUTIONSCENTOR_HOSTPKGJP" != '' ];then
   HOSTPKGJP=$BROTHERSOLUTIONSCENTOR_HOSTPKGJP
fi

if [ "$BROTHERSOLUTIONSCENTOR_HOSTPKGUS" != '' ];then
   HOSTPKGUS=$BROTHERSOLUTIONSCENTOR_HOSTPKGUS
fi


BASEPATHJP="/pub/com/linux/linuxj/"
BASEPATHUS="/pub/com/linux/linux/"




set_host_info(){
  DBG_MSG set_host_info
  if [ "$1" = "JPN" ];then
      URL_INF="https://"${HOSTINFJP}${BASEPATHJP}infs
      URL_PKG="https://"${HOSTPKGJP}${BASEPATHJP}packages
  else
      URL_INF="https://"${HOSTINFUS}${BASEPATHUS}infs
      URL_PKG="https://"${HOSTPKGUS}${BASEPATHUS}packages
  fi
  DBG_MSG "  URL_INF="$URL_INF
  DBG_MSG "  URL_PKG="$URL_PKG
}


network_check(){
  netchkpage=$1
  if [ "${wkdir}" != '' ] && [ "$netchkpage" != '' ];then
    if [ -f ${wkdir}/$netchkpage ];then
      rm  ${wkdir}/$netchkpage   2> /dev/null
    fi
  fi

  fulpath2="https://"${HOSTINFUS}${BASEPATHUS}infs/$netchkpage
  wget $WGET_OP2 $CACHEFLG -P ${wkdir} $fulpath2    > /dev/null 2> /dev/null 
  rcwget=$?

  netaccess=FALSE
  if [ -f ${wkdir}/$netchkpage ];then
     netaccess=SUCCESS
     rm  ${wkdir}/$netchkpage   2> /dev/null
  fi
}

drv_get_and_install(){
  DBG_MSG drv_get_and_install
  package=$1
  license=$2
  default=$3
  iinstall_result=No

  if [ "$package" != '' ];then
    echo -e $COLOR4$MESSAGE150$MONO #"You are going to install ...."
    echo -e $COLOR4"   "$package$MONO
    if [ "$default" = No ];then
      echo -e -n $COLOR$MESSAGE160        #"OK\? [y/N]  ->"
      answer=""
      read answer
      echo -e $MONO
      if [ "$answer" = Y ] || [ "$answer" = y ]; then
	if ! [ -f "$package" ];then
	    $license
	    echo -e -n $COLOR$MESSAGE170        #"Are you agree\? [Y/n] ->"
	    answer=""
	    read answer
	    echo -e $MONO
	    if [ "$answer" != N ] && [ "$answer" != n ]; then
		echo wget $WGET_OP $CACHEFLG $URL_PKG/$package
		wget $WGET_OP $CACHEFLG $URL_PKG/$package
	    fi
	    if [ -f "$package" ];then
               echo -n -e $COLOR4
	       echo $PKGCMD  $package
               echo -n -e $MONO
               if [ "$DEBUG_NOINSTALL" != 'yes' ];then
                 pre_proc
	         $PKGCMD  $package
               else
                 sleep 1
               fi
	       iinstall_result=Yes
	    fi

	fi
      fi                            #answer
    elif [ "$default" = Yes ];then
      echo -e -n $COLOR$MESSAGE165        #"OK\? [Y/n]  ->"
      answer=""
      read answer
      echo -e $MONO
      if [ "$answer" != N ] && [ "$answer" != n ]; then
	 if ! [ -f "$package" ];then
	    $license
	    echo -e -n $COLOR$MESSAGE170        #"Are you agree\? [Y/n] ->"
	    answer=""
	    read answer
	    echo -e $MONO
	    if [ "$answer" != N ] && [ "$answer" != n ]; then
		echo wget $WGET_OP $CACHEFLG $URL_PKG/$package
		wget $WGET_OP $CACHEFLG $URL_PKG/$package
	    fi

	    if [ -f "$package" ];then
              echo -n -e $COLOR4
	      echo $PKGCMD  $package
              echo -n -e $MONO
              if [ "$DEBUG_NOINSTALL" != 'yes' ];then
                pre_proc
	        $PKGCMD  $package
              else
                sleep 1
              fi
	      iinstall_result=Yes
	    fi
	 fi
      fi                              #answer
    else             # deault = Force
      if ! [ -f "$package" ];then
	 $license
	 echo -e -n $COLOR$MESSAGE170        #"Are you agree\? [Y/n] ->"
	 answer=""
	 read answer
	 echo -e $MONO
	 if [ "$answer" != N ] && [ "$answer" != n ]; then
	    echo wget $WGET_OP $CACHEFLG $URL_PKG/$package
	    wget $WGET_OP $CACHEFLG $URL_PKG/$package
	 fi
       fi
       if [ -f "$package" ];then
         echo -n -e $COLOR4
         echo $PKGCMD  $package
         echo -n -e $MONO
         if [ "$DEBUG_NOINSTALL" != 'yes' ];then
           pre_proc
	   $PKGCMD  $package
           iinstall_result=Yes
         else
           sleep 1
         fi
       fi
    fi                                #default
  fi                                  #package
}


make_generic_uninstaller(){
    DBG_MSG make_generic_uninstaller
    if [ -f $1 ];then
	generic_uninstaller=uninstaller_$2
	cat <<GENERICUNINST   > $generic_uninstaller
#! /bin/bash
$RMPKGCMD       $2

$(rmscanlibmodules $3)

GENERICUNINST
    chmod 744 $generic_uninstaller
    fi
}

make_brscan_uninstaller(){
    DBG_MSG make_brscan_uninstaller
    if [ -f $1 ];then
	brscan_uninstaller=uninstaller_$2
	cat <<BRSCANUNINST   > $brscan_uninstaller
#! /bin/bash

touch /usr/local/Brother/sane/dummy
$RMPKGCMD       $2
rm -f /usr/local/Brother/sane/dummy
rmdir --ignore-fail-on-non-empty /usr/local/Brother/sane 2>/dev/null

$(rmscanlibmodules $3)
BRSCANUNINST
        chmod 744 $brscan_uninstaller
    fi
}

make_brscan2_uninstaller(){
    DBG_MSG make_brscan2_uninstaller
    if [ -f $1 ];then
	brscan2_uninstaller=uninstaller_$2
	cat <<BRSCAN2UNINST   > $brscan2_uninstaller
#! /bin/bash

touch /usr/local/Brother/sane/dummy
$RMPKGCMD       $2
rm -f /usr/local/Brother/sane/dummy
rmdir --ignore-fail-on-non-empty /usr/local/Brother/sane 2>/dev/null

$(rmscanlibmodules $3)
BRSCAN2UNINST
        chmod 744 $brscan2_uninstaller
    fi
}



scanlibmodules1="\
libbrcolm.so.1.0.1 \
libbrscandec.so.1.0.0 \
sane/libsane-brother.so.1.0.7 \
sane/libsane-brother.so \
sane/libsane-brother.so.1 \
libbrscandec.so.1 \
libbrcolm.so \
libbrcolm.so.1 \
libbrscandec.so"

scanlibmodules2="\
libbrscandec2.so.1.0.0 \
sane/libsane-brother2.so.1.0.7 \
sane/libsane-brother2.so.1 \
sane/libsane-brother2.so \
libbrcolm2.so.1.0.1 \
libbrcolm2.so \
libbrscandec2.so.1 \
libbrscandec2.so \
libbrcolm2.so.1"

scanlibmodules3="\
libbrscandec3.so.1.0.0 \
sane/libsane-brother3.so.1.0.7 \
sane/libsane-brother3.so.1 \
sane/libsane-brother3.so \
libbrscandec3.so \
libbrscandec3.so.1"


scanlibmodules4=""


dellist=''
cpscanlibmodules(){
  for file in $1
  do
    lib64mod=/usr/lib64/$file
    libmod=/usr/lib/$file

    if [ -f $lib64mod ];then
      if [ -d /usr/lib ];then
        if [ ! -f $libmod ];then
           cp $lib64mod  $libmod 2> /dev/null
           if [ -f $libmod ];then
             dellist2=$(echo $dellist $libmod)
             dellist=$dellist2
           fi
        fi
      fi
    fi
  done
}


rmscanlibmodules(){
  for file in $dellist
  do
    for check in $*
    do
      chkresult=$(echo $file | grep $check\$ )
      if [ "$chkresult" !=  '' ];then
        echo rm  -f $file 
      fi
    done
    
  done
}

udevrulefile=""
udev_installed=no
udev_install(){
libsanerule=$(ls /lib/udev/rules.d/*.rules /etc/udev/rules.d/*.rules | \
    grep libsane | head --line=1)
number=$(echo $libsanerule | \
    sed s/"\/lib\/udev\/rules.d\/"//g |\
    sed s/"\/etc\/udev\/rules.d\/"//g |\
    head --bytes=2)
chk=$(echo $number | grep "[0-9][0-9]")
if [ "$chk" = '' ];then
    libsanerule=$(ls /lib/udev/rules.d/*.rules /etc/udev/rules.d/*.rules | \
	grep sane-backends | head --line=1)
    number=$(echo $libsanerule | \
	sed s/"\/lib\/udev\/rules.d\/"//g |\
        sed s/"\/etc\/udev\/rules.d\/"//g |\
        head --bytes=2)
fi
chk=$(echo $number | grep "[0-9][0-9]")
if [ "$chk" != '' ];then
  chk=$(grep "ENV{libsane_matched}=\"yes\""  $libsanerule | tail -1)
  if [ "$chk" != '' ];then

####
    udevrulefile="/etc/udev/rules.d/${number}-brother-libsane-type1-inst.rules"
    cat <<  %%_UDEV_RULE_%% > $udevrulefile
#
#   udev rules sample for Brother MFP
#         version 1.0.2-0
#
#   Copyright (C) 2012-2017 Brother. Industries, Ltd.
#
#   copy to /etc/udev/rules.d or /lib/udev/rules.d
#

ACTION!="add", GOTO="brother_mfp_end"
SUBSYSTEM=="usb", GOTO="brother_mfp_udev_1"
SUBSYSTEM!="usb_device", GOTO="brother_mfp_end"
LABEL="brother_mfp_udev_1"
SYSFS{idVendor}=="04f9", GOTO="brother_mfp_udev_2"
ATTRS{idVendor}=="04f9", GOTO="brother_mfp_udev_2"
GOTO="brother_mfp_end"
LABEL="brother_mfp_udev_2"
ATTRS{bInterfaceClass}!="0ff", GOTO="brother_mfp_end"
ATTRS{bInterfaceSubClass}!="0ff", GOTO="brother_mfp_end"
ATTRS{bInterfaceProtocol}!="0ff", GOTO="brother_mfp_end"
#MODE="0666"
#GROUP="scanner"
ENV{libsane_matched}="yes"
#SYMLINK+="scanner-%k"
LABEL="brother_mfp_end"
%%_UDEV_RULE_%%
####
   chmod 644    $udevrulefile
   udev_installed=yes
  fi
fi
}



scanner_install(){
  DBG_MSG scanner_install

  case "$SCANNER_DRV"  in
    "brscan")
      drv_get_and_install $SCANFILE gpl_and_br_license  Force
      if [ $iinstall_result = Yes ];then
        cpscanlibmodules "$scanlibmodules1"
        make_brscan_uninstaller  $SCANFILE  "$SCANNER_DRV" "$scanlibmodules1"
        install_done=yes
      fi
      scanconfig=brsaneconfig
      drv_get_and_install $SKEYFILE brother_license  Force
      if [ $iinstall_result = Yes ];then
          dellist=''
          make_generic_uninstaller $SKEYFILE  brscan-skey
          install_done=yes
      fi
      ;;
    "brscan2")
      drv_get_and_install $SCANFILE gpl_and_br_license  Force
      if [ $iinstall_result = Yes ];then
        cpscanlibmodules "$scanlibmodules2"
        make_brscan2_uninstaller $SCANFILE  "$SCANNER_DRV" "$scanlibmodules2"
        install_done=yes
      fi
      scanconfig=brsaneconfig2
      drv_get_and_install $SKEYFILE brother_license  Force
      if [ $iinstall_result = Yes ];then
          dellist=''
          make_generic_uninstaller $SKEYFILE  brscan-skey
          install_done=yes
      fi
      ;;
    "brscan3")
      drv_get_and_install $SCANFILE gpl_and_br_license  Force
      if [ $iinstall_result = Yes ];then
        cpscanlibmodules "$scanlibmodules3"
        make_generic_uninstaller $SCANFILE  "$SCANNER_DRV" "$scanlibmodules3"
        install_done=yes
      fi
      scanconfig=brsaneconfig3
      drv_get_and_install $SKEYFILE brother_license  Force
      if [ $iinstall_result = Yes ];then
          dellist=''
          make_generic_uninstaller $SKEYFILE  brscan-skey
          install_done=yes
      fi
      ;;
    "brscan4")
      drv_get_and_install $SCANFILE brother_license  Force
      if [ $iinstall_result = Yes ];then
        cpscanlibmodules "$scanlibmodules4"
        make_generic_uninstaller $SCANFILE  "$SCANNER_DRV" "$scanlibmodules4"
        install_done=yes
      fi
      scanconfig=brsaneconfig4
      drv_get_and_install $SKEYFILE brother_license  Force
      if [ $iinstall_result = Yes ];then
          dellist=''
          make_generic_uninstaller $SKEYFILE  brscan-skey
          install_done=yes
      fi
      ;;
    "brscan5")
      drv_get_and_install $SCANFILE brother_license  Force
      if [ $iinstall_result = Yes ];then
        cpscanlibmodules "$scanlibmodules5"
        make_generic_uninstaller $SCANFILE  "$SCANNER_DRV" "$scanlibmodules5"
        install_done=yes
      fi
      scanconfig=brsaneconfig5
      drv_get_and_install $SKEYFILE brother_license  Force
      if [ $iinstall_result = Yes ];then
          dellist=''
          make_generic_uninstaller $SKEYFILE  brscan-skey
          install_done=yes
      fi
      ;;

    * )
      ;;
  esac

  udev_install

  if [ $udev_installed = yes ];then
      echo   rm $udevrulefile  >> uninstaller_${SCANNER_DRV}
  fi

  # install libusb-0.1-4 if not available

  libusbchk=$(ls -R /lib /usr/lib /usr/sbin | grep 'libusb-0.1.so.4')

  if [ "$libusbchk" = '' ];then
      if [ "$(which apt-get 2>/dev/null)" != '' ];then
	  echo apt-get install libusb-0.1-4
	  apt-get install libusb-0.1-4
      fi
  fi

  # libusb-0.1-4

  post_proc

  if [ "$scanconfig" != '' ] && \
     [ "$PRODUCT_NAME" != '' ] && \
     [ -f "$(which $scanconfig)" ];then
    if [ "$(echo $deviceuri | grep 'usb://')" = '' ];then
      if [ "$(echo $deviceuri | grep 'file://')" = '' ];then
       if [ "$ipadrs" = '' ];then
         echo -e -n $COLOR$MESSAGE220          #"  enter IP address ->"
         read ipadrs
         echo -e $MONO
       fi
      fi
      echo -n -e $COLOR4
      echo $scanconfig -a name=$PRODUCT_NAME model=$PRODUCT_NAME ip=$ipadrs
      echo -n -e $MONO
      $scanconfig -a name=$PRODUCT_NAME model=$PRODUCT_NAME ip=$ipadrs
    fi
  fi

}

pre_proc(){
  if [ "$preproc_done" = '' ];then
    if [ "$PREPROC" != '' ];then
       echo "$PREPROC"   | /bin/bash
    fi
  fi
  preproc_done=done
}

post_proc(){
  if [ "$install_done" = yes ];then
    if [ "$postproc_done" = '' ];then
      if [ "$POSTPROC" != '' ];then
         echo "$POSTPROC"   | /bin/bash
      fi
    fi
    postproc_done=done
  fi
}

cleanup_deb_cups_pkg(){
 if [ "$PKG" = deb ];then
  if [ "$(which awk 2> /dev/null)" != '' ];then
    installedpkgs=$($LSPKGCMD | grep -i cups | grep -i brother | \
                                awk '{print $2}')
    for pkg in $installedpkgs
    do
      pkg2=$(echo $pkg | sed s/":.*$"//g)
      if [ "$(echo $CUPSFILE | grep $pkg2 )" != '' ];then
        $RMPKGCMD $pkg
        break             
      fi
    done
  fi
 fi
}


ipadrs=''
deviceuri="usb://"
PRODUCT_NAME=''

#
#  START  (MAIN)
#

HIDE_INF=YES

if [ "$(echo $0 | grep  linux-brjprinter-installer)" = '' ];then
  REGION=US
else
  REGION=JPN
fi


DBG_MSG MAIN
dlresult=IDENTIC
lnk_flag='    '

if [ "$1" = '-h' ] || [ "$1" = '--help' ];then
   echo -e $COLOR"$MESSAGE010"$0"$MESSAGE020"$MONO    #"USAGE:  $0  model"
   echo -e $COLOR"$MESSAGE012"$0"$MESSAGE030"$MONO    #"USAGE:  $0  -f model"
   echo -e $COLOR"$MESSAGE012"$0"$MESSAGE040"$MONO    #"USAGE:  $0  -l "
   #DBG_MSG  "exit 2"
   rmdir "${wkdir}"
   exit 0
fi

if [ $(whoami) != 'root' ];then
    echo -e  $COLOR$MESSAGE050$MONO       #"Only root can do this operation."
    #DBG_MSG  "exit 5"
    rmdir "${wkdir}"
    exit 0
fi

if [ ! -f /etc/init.d/cups ] && [ ! -f /etc/init.d/cupsys ];then 
 if [ "$(which lpadmin 2> /dev/null)" = '' ];then
  echo -e $COLOR$MESSAGE060$MONO                  #"CUPS is not installed."
  if [ "$1" = '' ];then
    echo -e -n $COLOR$MESSAGE240$MONO    #"Hit Return/Enter Key"
    read answer
  fi
  #DBG_MSG  "exit 6"
  rmdir "${wkdir}"
  exit 0
 fi
fi

LIB64FLT=/usr/lib64/cups/filter
LIB32FLT=/usr/lib32/cups/filter
LIBFLT=/usr/lib/cups/filter


TESTPRINT=/usr/share/cups/data/testprint.ps
TESTPRINT2=/usr/share/cups/data/testprint


## sweep
pre_install_sweep



package_list=NO
CACHEFLG='--no-cache'


infcheck=0
if  [ "$1" = '--inf-check=1' ];then
   infcheck=1
   package_list=TEXT
fi
if  [ "$1" = '--inf-check=2' ];then
   infcheck=2
   package_list=CSV
fi
if  [ "$1" = '--inf-check=3' ];then
   infcheck=3
   package_list=CSV
fi
if  [ "$1" = '--inf-check=4' ];then
   infcheck=4
   package_list=CSV
fi
if  [ "$1" = '--inf-check=5' ];then
   infcheck=5
   package_list=CSV
fi



if [ $package_list = TEXT ];then
  echo -e -n $MONO
fi


if [ "$(which wget 2> /dev/null)" = '' ];then
  if   [ "$(which yum 2>/dev/null)" != '' ];then
     echo yum install wget
     yum install wget
  elif [ "$(which dnf 2>/dev/null)" != '' ];then
     echo dnf install wget
     dnf install wget
  elif [ "$(which apt-get 2>/dev/null)" != '' ];then
     echo apt-get install wget
     apt-get install wget
  fi
fi


if [ "$(which wget 2> /dev/null)" = '' ];then
  echo -e -n $COLOR$MESSAGE280             #"wget is required."
  echo -e $MONO
  #DBG_MSG  "exit 7"
  rmdir "${wkdir}"
  exit 0
fi

post_install_sweep 





if [ "$(which dpkg 2> /dev/null)" != '' ];then
   PKG=deb
elif [ "$(which rpm 2> /dev/null)" != '' ];then
   PKG=rpm
else
   echo -e $COLOR$MESSAGE122$MONO     #"Rpm or dpkg is required."
   post_install_sweep 
   if [ "$1" = '' ];then
     echo -e -n $COLOR$MESSAGE240$MONO    #"Hit Return/Enter Key"
     read answer
   fi
   #DBG_MSG  "exit 9"
   rmdir "${wkdir}"
   exit 0
fi


if [ "$PKG" = deb ];then
 if [ "$(which awk 2> /dev/null)" = '' ];then
  if [ "$(which apt-get 2>/dev/null)" != '' ];then
     echo apt-get install mawk
     apt-get install mawk
  fi
 fi
fi



if [ "$BROTHER_INSRALLER_FAKE_PKG" != '' ];then
   PKG=$BROTHER_INSRALLER_FAKE_PKG
fi

if [ "$PKG" = deb ];then
  PKGCMD='dpkg  -i --force-all'
  RMPKGCMD='dpkg  -P'
  LSPKGCMD='dpkg  --list'
  EXT='\.deb'
  PKG=deb
elif [ "$PKG" = rpm ];then
  PKGCMD='rpm  -ihv  --nodeps  --replacefiles --replacepkgs'
  RMPKGCMD='rpm -e'
  LSPKGCMD='rpm -qa'
  EXT='\.rpm'
  PKG=rpm
fi

if [ "$1" = '-f' ]             || \
   [ "$1" = '--find' ]         || \
   [ "$1" = '--inf-check=1' ] || \
   [ "$1" = '--inf-check=2' ] || \
   [ "$1" = '--inf-check=3' ] || \
   [ "$1" = '--inf-check=4' ] || \
   [ "$1" = '--inf-check=5' ] || \
   [ "$1" = '--inf-check=6' ] || \
   [ "$1" = '-p' ];then
 MODEL_tmp=$(echo $2 | sed s/'-'//g)
elif [ "$1" = '' ];then
 echo -e -n $COLOR$MESSAGE121       #"Input model name->"
 read modelinput
 echo -e $MONO
 MODEL_tmp=$(echo $modelinput | sed s/'-'//g)
else
 MODEL_tmp=$(echo $1 | sed s/'-'//g)
fi

if [ "$(echo $MODEL_tmp | grep '@')" = '' ];then
  MODEL=$MODEL_tmp
  DEBUG_NOINSTALL='no'
else
  MODEL=$(echo $MODEL_tmp | tr -d '@')
  DEBUG_NOINSTALL='yes'
fi

if [ "$(echo $MODEL_tmp | grep '\[')" = '' ];then
  MODEL=$MODEL_tmp
  NODOWNLOAD=0
else
  INFPATH="$(echo $MODEL_tmp | tr -d '[' | tr -d ']' )"
  if [ ! -f $INFPATH ];then
    echo -e $COLOR$MESSAGE130$MONO
    rmdir "${wkdir}"
    exit 0
  fi
  MODEL=$(echo $MODEL_tmp | tr -d '[' | tr -d ']' | sed -e s/"^.*\/"//g)

  NODOWNLOAD=1
fi



LPRFILE=""
CUPSFILE=""
PDRVFILE=""
SCANFILE=""
SKEYFILE=""


wkdir=$(mktemp -d /tmp/brprinter-installer_XXXXXX)
packdir=brother_driver_packdir
basedir=$(pwd)

modelnhuc=""
mkdir -p "$wkdir" 

REGION2=$REGION


if [ -s "$(echo $1 | grep -e .${PKG})"   ]      && \
   [ -s "$(echo $2 | grep -e .${PKG})"   ]      && \
   [ -s "$(echo $1 | grep -e 'lp' -e 'cups')"   ] && \
   [ -s "$(echo $2 | grep -e 'lp' -e 'cups')"   ] && \
   [ -f $1 ] && \
   [ -f $2 ] ; then

   #install local files

   tmpcup=$(echo $1 | grep cups)
   tmplpr=$(echo $2 | grep lp)
   if [ "$tmpcup" = '' ] || [ "$tmplpr" = '' ];then
      tmpcup=$(echo $2 | grep cups)
      tmplpr=$(echo $1 | grep lp)
   fi

   if [ "$tmpcup" = '' ] || [ "$tmplpr" =  '' ];then
      echo -e $COLOR$MESSAGE130$MONO     #"Install packages does not be found."
      rmdir "${wkdir}"
      exit 0
   fi

   echo [UNKNOWN]            >  $wkdir/LOCAL
   echo PRN_CUP_RPM=$tmpcup  >> $wkdir/LOCAL
   echo PRN_CUP_DEB=$tmpcup  >> $wkdir/LOCAL
   echo PRN_LPD_RPM=$tmplpr  >> $wkdir/LOCAL
   echo PRN_LPD_DEB=$tmplpr  >> $wkdir/LOCAL
   echo PRN_DRV_RPM=$tmplpr  >> $wkdir/LOCAL
   echo PRN_DRV_DEB=$tmplpr  >> $wkdir/LOCAL
   echo PRINTERNAME=UNKNOWN  >> $wkdir/LOCAL
   echo SCANNER_DRV=         >> $wkdir/LOCAL
   echo SCANKEY_DRV=         >> $wkdir/LOCAL

   MODEL=LOCAL
   NODOWNLOAD=2

fi

# network check

netaccess=FALSE
network_check  HL5470DW
if [ $netaccess != SUCCESS ];then
   network_check  MFCJ6710CDW
fi

if [ $netaccess != SUCCESS ];then

    echo -e -n $COLOR$MESSAGE070  #"Will you specify the PROXY server\? [y/N] ->"
    read answer
    if [ "$answer" = Y ] || [ "$answer" = y ]; then

      #"enter PROXY server URL "
      #"   ex https://\(proxy-server-url\):\(port\)"
      #"   ex https://\(login-name\):\(pass-word\)@\(proxy-server-url\):\(port\)"
      #"     ->"

      echo -e $COLOR$MESSAGE080
      echo -e $COLOR$MESSAGE090
      echo -e $COLOR$MESSAGE100
      echo -e -n $COLOR$MESSAGE110
      read proxy
      echo -e $MONO
      export https_proxy=$proxy
      network_check  HL5470DW
      if [ $netaccess != SUCCESS ];then
         network_check  MFCJ6710CDW
      fi
      if [ $netaccess != SUCCESS ];then
        echo -e $COLOR$MESSAGE120$MONO    
	rmdir "${wkdir}"
        exit 0
      fi
    else
      echo -e $COLOR$MESSAGE120$MONO    
      rmdir "${wkdir}"
      exit 0
    fi
fi




set_host_info $REGION
get_inf_file  $MODEL  $wkdir

if [ $REGION = JPN ];then
  if [ ! -f ${wkdir}/${modelnhuc} ] || [ "${modelnhuc}" = '' ];then
    REGION=US
    modelnhuc=''
    set_host_info $REGION
    get_inf_file  $MODEL  $wkdir
    REGION=JPN
  fi
fi

if [ $infcheck = 0 ];then
  if [ ! -f ${wkdir}/${modelnhuc} ] || [ "${modelnhuc}" = '' ];then
    netaccess=FALSE
    network_check  HL5470DW
    if [ $netaccess != SUCCESS ];then
       network_check  MFCJ6710CDW
    fi

    if [ $netaccess = SUCCESS ];then
      echo -e $COLOR$MESSAGE130$MONO     #"Install packages does not be found."
      echo -e $COLOR$MESSAGE140$MONO     #" Confirm the model name."
      echo -e $MONO
      rmdir "${wkdir}"
      exit 0
    fi
    echo -e -n $COLOR$MESSAGE070  #"Will you specify the PROXY server\? [y/N] ->"
    read answer
    if [ "$answer" = Y ] || [ "$answer" = y ]; then

      #"enter PROXY server URL "
      #"   ex https://\(proxy-server-url\):\(port\)"
      #"   ex https://\(login-name\):\(pass-word\)@\(proxy-server-url\):\(port\)"
      #"     ->"

      echo -e $COLOR$MESSAGE080
      echo -e $COLOR$MESSAGE090
      echo -e $COLOR$MESSAGE100
      echo -e -n $COLOR$MESSAGE110
      read proxy
      echo -e $MONO
      export https_proxy=$proxy
    else
      echo -e $MONO
      #DBG_MSG  "exit 10"
      rmdir "${wkdir}"
      exit 0
    fi
    echo -e $MONO
    REGION=$REGION2

    set_host_info $REGION
    get_inf_file  $MODEL  $wkdir

    if [ $REGION = JPN ];then
      if [ ! -f ${wkdir}/${modelnhuc} ] || [ "${modelnhuc}" = '' ];then
        REGION=US
        modelnhuc=''
        set_host_info $REGION
        get_inf_file  $MODEL  $wkdir
      fi
      REGION=JPN
    fi
  fi
fi

if [ ! -f ${wkdir}/${modelnhuc} ] || [ "${modelnhuc}" = '' ];then
  #"Cannot get server information. Confirm the network."
  if [ $infcheck = 0 ];then
    echo -e $COLOR$MESSAGE120$MONO    
    rmdir "${wkdir}"
    exit 0
  fi
  if [ $package_list = TEXT ];then
    echo "PACKAGE:PRNL="$LPRFILE
    echo "PACKAGE:PRNC="$CUPSFILE
    echo "PACKAGE:PDRV="$PDRVFILE
    echo "PACKAGE:SCAN="$SCANFILE
    echo "PACKAGE:SKEY="$SKEYFILE
    rmdir "${wkdir}"
    exit 0
  fi
  if [ $package_list = CSV ];then
    echo "$2"":,"$PKG",${dlresult},${lnk_flag}"\
         ,$LPRFILE,$CUPSFILE,$PDRVFILE,$SCANFILE,$SKEYFILE
    rmdir "${wkdir}"
    exit 0
  fi

  touch brother-drivers/"$0".log
  dlresult="FALSE  "
  lnk_flag="       "
  rccups="       "
  rclpr="       "
  rcscan="       "
  rcskey="       "

  if [ "$infcheck" = 3 ];then
     echo "$2"":,"$PKG",${dlresult},${lnk_flag}","$SCANNER_DRV"\
         ,$rccups,$rclpr,$rcscan,$rcskey\
 	  >>  brother-drivers/"$0".log
     rm -fR brother-drivers/$2   2> /dev/null
  fi

  if [ "$infcheck" = 4 ] || [ "$infcheck" = 5 ];then

     echo "$2"":,"$PKG",${dlresult},${lnk_flag}","$SCANNER_DRV"\
         ,$rccups,$rclpr,$rcscan,$rcskey\
         ,$LPRFILE,$CUPSFILE,$PDRVFILE,$SCANFILE,$SKEYFILE \
  	  >>  brother-drivers/"$0".log
  fi

  rmdir "${wkdir}"
  exit 0
fi

arch=$(uname -m | grep "amd64")
if [ "$arch" = '' ];then
  arch=$(uname -m | grep "x86_64")
fi
if [ "$arch" = '' ];then
  arch=i386
fi

if [ "$BROTHER_INSRALLER_FAKE_ARC" != '' ];then
  arch=$BROTHER_INSRALLER_FAKE_ARC
fi

get_packages_name ${modelnhuc}

if [ -f ${wkdir}/${modelnhuc} ];then
   rm -f ${wkdir}/${modelnhuc}   2> /dev/null
fi

if [ $infcheck = 1 ];then
  echo "PACKAGE:PRNL="$LPRFILE
  echo "PACKAGE:PRNC="$CUPSFILE
  echo "PACKAGE:PDRV="$PDRVFILE
  echo "PACKAGE:SCAN="$SCANFILE
  echo "PACKAGE:SKEY="$SKEYFILE
  rmdir "${wkdir}"
  exit 0
fi
if [ $infcheck = 2 ];then
  echo "$2"":,"$PKG",${dlresult},${lnk_flag}"\
         ,$LPRFILE,$CUPSFILE,$PDRVFILE,$SCANFILE,$SKEYFILE
  rmdir "${wkdir}"
  exit 0
fi



if [ "$infcheck" -ge 3 ];then
  rccups='N/A    '
  rclpr='N/A    '
  rcscan='N/A    '
  rcskey='N/A    '

  dwkdir=brother-drivers/$2
  mkdir -p $dwkdir
  if [ "$CUPSFILE" != '' ];then
    rccups="FALSE  "
    wget $WGET_OP '-nc' $URL_PKG/$CUPSFILE   -P $dwkdir
  fi
  if [ "$LPRFILE" != '' ];then
    rclpr="FALSE  "
    wget $WGET_OP '-nc' $URL_PKG/$LPRFILE    -P $dwkdir
  fi
  if [ "$PDRVFILE" != '' ];then
    rcpdrv="FALSE  "
    wget $WGET_OP '-nc' $URL_PKG/$PDRVFILE    -P $dwkdir
  fi
  if [ "$SCANFILE" != '' ];then
    rcscan="FALSE  "
    wget $WGET_OP '-nc' $URL_PKG/$SCANFILE   -P $dwkdir
  fi
  if [ "$SKEYFILE" != '' ];then
    rcskey="FALSE  "
    wget $WGET_OP '-nc' $URL_PKG/$SKEYFILE   -P $dwkdir
  fi
 
  # -------------
  if [ "$CUPSFILE" != '' ];then
    if [ -f $dwkdir/$CUPSFILE ];then
      rccups=SUCCESS
    fi
  fi
  if [ "$LPRFILE" != '' ];then
    if [ -f $dwkdir/$LPRFILE ];then
      rclpr=SUCCESS
    fi
  fi
  if [ "$PDRVFILE" != '' ];then
    if [ -f $dwkdir/$PDRVFILE ];then
      rcpdrv=SUCCESS
    fi
  fi
  if [ "$SCANFILE" != '' ];then
    if [ -f $dwkdir/$SCANFILE ];then
      rcscan=SUCCESS
    fi
  fi
  if [ "$SKEYFILE" != '' ];then
    if [ -f $dwkdir/$SKEYFILE ];then
      rcskey=SUCCESS
    fi
  fi

  # -------------

  touch brother-drivers/"$0".log

  if [ "$infcheck" = 3 ];then
     echo "$2"":,${modelnhuc},"$PKG",${dlresult},${lnk_flag}","$SCANNER_DRV"\
         ,$rccups,$rclpr,$rcscan,$rcskey\
 	  >>  brother-drivers/"$0".log
  fi

  if [ "$infcheck" = 4 ] || [ "$infcheck" = 5 ];then

     echo "$2"":,${modelnhuc},"$PKG",${dlresult},${lnk_flag}","$SCANNER_DRV"\
         ,$rccups,$rclpr,$rcscan,$rcskey\
         ,$LPRFILE,$CUPSFILE,$PDRVFILE,$SCANFILE,$SKEYFILE \
  	  >>  brother-drivers/"$0".log
  fi

  if [ "$infcheck" = 3 ] || [ "$infcheck" = 4 ];then
     rm -fR brother-drivers/$2   2> /dev/null
  fi
  rmdir "${wkdir}"
  exit 0
fi


if [ "$CUPSFILE" = '' ] && [ "$LPRFILE" = '' ] && [ "$PDRVFILE" = '' ] && [ "$SCAN" = '' ];then
  echo -e $COLOR$MESSAGE130$MONO     #"Install packages does not be found."
  echo -e $COLOR$MESSAGE140$MONO     #" Confirm the model name."

  post_install_sweep 

  if [ "$1" = '' ];then
    echo -e -n $COLOR$MESSAGE240$MONO    #"Hit Return/Enter Key"
    read answer
  fi
  #DBG_MSG  "exit 12"
  rmdir "${wkdir}"
  exit 0
fi


if [ "$1" = '-f' ] || [ "$1" = '--find' ];then
  echo $LPRFILE
  echo $CUPSFILE
  echo $PDRVFILE
  echo $SCANFILE
  echo $SKEYFILE

  post_install_sweep 
  #DBG_MSG  "exit 13"
  rmdir "${wkdir}"
  exit 0
fi




PREPKGCMDC=''
PREPKGCMDL=''
PREPKGCMDP=''
if [ "$PKG" = deb ];then
  if [ "$CUPSFILE" != '' ];then
    PREPKGCMDC="dpkg  -x $CUPSFILE /"
  fi
  if [ "$PDRVFILE" != '' ];then
    PREPKGCMDP="dpkg  -x $PDRVFILE /"
  fi
  if [ "$LPRFILE" != '' ];then
    PREPKGCMDL="dpkg  -x $LPRFILE /"
  fi
fi

post_install_sweep 


echo -e $COLOR4$MESSAGE150$MONO      #"You are going to install  following packages."

if [ "$LPRFILE" != '' ];then
  echo -e $COLOR4"   "$LPRFILE$MONO
fi
if [ "$CUPSFILE" != '' ];then
  echo -e $COLOR4"   "$CUPSFILE$MONO
fi
if [ "$PDRVFILE" != '' ];then
  echo -e $COLOR4"   "$PDRVFILE$MONO
fi

if [ "$SCANFILE" != '' ];then
  echo -e $COLOR4"   "$SCANFILE
fi
if [ "$SKEYFILE" != '' ];then
  echo -e $COLOR4"   "$SKEYFILE
fi



echo -e -n $COLOR$MESSAGE160        #"OK\? [y/N]  ->"

read answer
echo -e $MONO

if [ "$answer" != Y ] && [ "$answer" != y ]; then
    #scanner_install          #    scanner
    #DBG_MSG  "exit 14"
    rmdir "${wkdir}"
    exit 0
fi

if [ "$LPRFILE" != '' ];then
  if ! [ -f "$LPRFILE" ];then
    brother_license

    echo -e -n $COLOR$MESSAGE170        #"Are you agree\? [Y/n] ->"

    read answer
    echo -e $MONO

    if [ "$answer" = N ] || [ "$answer" = n ]; then
      scanner_install          #    scanner
      post_proc
      #DBG_MSG  "exit 15"
      rmdir "${wkdir}"
      exit 0
    fi


    if [ "$(which wget 2> /dev/null)" = '' ];then
      echo -e -n $COLOR$MESSAGE280             #"wget is required."
      echo -e $MONO
      #DBG_MSG  "exit 16"
      rmdir "${wkdir}"
      exit 0
    fi
    if [ ! -f $LPRFILE ];then
      rm -f $LPRFILE   2> /dev/null
      echo wget $WGET_OP $CACHEFLG $URL_PKG/$LPRFILE
      wget $WGET_OP $CACHEFLG $URL_PKG/$LPRFILE
    fi
  fi 
fi

if [ "$CUPSFILE" != '' ];then
  if ! [ -f "$CUPSFILE" ];then

    gpl_license

    echo -e -n $COLOR$MESSAGE180          #"Do you agree\? [Y/n] ->"
    read answer
    echo -e $MONO

    if [ "$answer" = N ] || [ "$answer" = n ]; then
      scanner_install          #    scanner
      post_proc
      #DBG_MSG  "exit 17"
      rmdir "${wkdir}"
      exit 0
    fi
    if [ "$(which wget 2> /dev/null)" = '' ];then
      echo -e -n $COLOR$MESSAGE280             #"wget is required."
      echo -e $MONO
      #DBG_MSG  "exit 18"
      rmdir "${wkdir}"
      exit 0
    fi

    if [ ! -f $CUPSFILE ];then
      rm -f $CUPSFILE   2> /dev/null
      echo wget $WGET_OP $CACHEFLG $URL_PKG/$CUPSFILE
      wget $WGET_OP $CACHEFLG $URL_PKG/$CUPSFILE
    fi

  fi
fi

#--
if [ "$PDRVFILE" != '' ];then
  if ! [ -f "$PDRVFILE" ];then

    pdrv_complex_license

    echo -e -n $COLOR$MESSAGE180          #"Do you agree\? [Y/n] ->"
    read answer
    echo -e $MONO

    if [ "$answer" = N ] || [ "$answer" = n ]; then
      scanner_install          #    scanner
      post_proc
      #DBG_MSG  "exit 17"
      rmdir "${wkdir}"
      exit 0
    fi
    if [ "$(which wget 2> /dev/null)" = '' ];then
      echo -e -n $COLOR$MESSAGE280             #"wget is required."
      echo -e $MONO
      #DBG_MSG  "exit 18"
      rmdir "${wkdir}"
      exit 0
    fi

    if [ ! -f $PDRVFILE ];then
      rm -f $PDRVFILE   2> /dev/null
      echo wget $WGET_OP $CACHEFLG $URL_PKG/$PDRVFILE
      wget $WGET_OP $CACHEFLG $URL_PKG/$PDRVFILE
    fi

  fi
fi




pre_proc

require_386lib=no
if [ "$arch" != 'i386' ];then
  require_386lib=yes
  if [ "$REQ32LIB" = 'NO' ] || \
     [ "$REQ32LIB" = 'No' ] || \
     [ "$REQ32LIB" = 'no' ];then
     require_386lib=no
  fi
fi 

if [ "$require_386lib" = yes ];then
  if [ "$(which dpkg 2>/dev/null)" != '' ];then
    ia32=$(dpkg -l | grep "ia32-libs")
    lib32=$(dpkg -l | grep "lib32stdc++6")

    if [ "$ia32" = '' ] || [ "$lib32" = '' ];then
       apt-get update
    fi

    if [ "$ia32" = '' ];then
       apt-get install ia32-libs
    fi
    lib32=$(dpkg -l | grep "lib32stdc++6")
    if [ "$lib32" = '' ];then
       apt-get install lib32stdc++6
    fi
  fi
  #----------- check Fedor,CentOS,RedHat 64 --------------
  if [ -e /etc/fedora-release ] || [ -e /etc/fedora ] || \
     [ -e /etc/centos-release ] || [ -e /etc/centos ] || \
     [ -e /etc/redhat-release ] || [ -e /etc/redhat ]; then
    lib32=$(rpm -qa| grep glibc | grep i686)
    if [ "$lib32" = "" ];then
      if   [ "$(which yum 2>/dev/null)" != '' ];then
        echo yum install  glibc.i686
        yum install  glibc.i686
        echo yum install  libstdc++.i686
        yum install  libstdc++.i686
      else
        echo dnf install  glibc.i686
        dnf install  glibc.i686
        echo dnf install  libstdc++.i686
        dnf install  libstdc++.i686
      fi
    fi
  fi
fi


DUMMYCUPSYS=0
DUMMYCUPS=0
DUMMYLPD=0
DUMMYLPRNG=0
if ! [ -f /etc/init.d/cupsys ];then
 DUMMYCUPSYS=1
 ln -s /bin/true  /etc/init.d/cupsys
fi

if ! [ -f /etc/init.d/cups ];then
 DUMMYCUPS=1
 ln -s /bin/true  /etc/init.d/cups
fi

if ! [ -f /etc/init.d/lpd ];then
 DUMMYLPD=1
 ln -s /bin/true  /etc/init.d/lpd
fi

if ! [ -f /etc/init.d/lprng ];then
 DUMMYLPRNG=1
 ln -s /bin/true  /etc/init.d/lprng
fi

LPADMIN=lpadmin
LPINFO=lpinfo

if ! [ "$(which $LPADMIN 2> /dev/null)" ];then
   LPADMIN=/usr/sbin/lpadmin
fi

if ! [ "$(which $LPINFO 2> /dev/null)" ];then
  LPINFO=/usr/sbin/lpinfo
fi


mkmodeldir=0
if [ ! -d /usr/share/cups/model ];then
  mkdir -p /usr/share/cups/model
  mkmodeldir=1
fi


if [ "$PREPKGCMDL" != '' ];then
  echo  $PREPKGCMDL
  $PREPKGCMDL
fi
if [ "$PREPKGCMDC" != '' ];then
  echo  $PREPKGCMDC
  $PREPKGCMDC  
fi
if [ "$PREPKGCMDP" != '' ];then
  echo  $PREPKGCMDP
  $PREPKGCMDP
fi


if [ "$PKG" = deb ];then
  cleanup_deb_cups_pkg

  # for Ubuntu 11.04
  debfile=$(echo $LPRFILE | sed s/\.i386.deb/a\.i386.deb/g)
  mkdir -p $wkdir/$packdir

  if [ "$LPRFILE" != '' ];then

    cp $basedir/$LPRFILE $wkdir/$packdir
    cd $wkdir/$packdir

    dpkg-deb -e $LPRFILE  DEBIAN
    dpkg -x $LPRFILE  ./

    cat DEBIAN/control \
	   | sed s/Depends.*$//g \
           | tr -s '\n' \
	   > DEBIAN/control.tmp

    mv -f DEBIAN/control.tmp DEBIAN/control

    rm -f $LPRFILE   2> /dev/null
    rm -fR usr/share/doc/*   2> /dev/null
    LPRFILE=$debfile

    cd $wkdir
    dpkg -b ./$packdir $debfile
    echo dpkg -b ./$packdir $debfile

    rm -fR $wkdir/$packdir/*    2> /dev/null
  fi

  if [ "$CUPSFILE" != '' ];then
    debfile=$(echo $CUPSFILE | sed s/\.i386.deb/a\.i386.deb/g)
  
    cp $basedir/$CUPSFILE $wkdir/$packdir
    cd $wkdir/$packdir

    dpkg-deb -e $CUPSFILE  DEBIAN
    dpkg -x $CUPSFILE  ./

    cat DEBIAN/control \
	   | sed s/Depends.*$//g \
           | tr -s '\n' \
	   > DEBIAN/control.tmp

    mv -f DEBIAN/control.tmp DEBIAN/control

    rm -f $CUPSFILE   2> /dev/null
    rm -fR usr/share/doc/*   2> /dev/null
    cd $wkdir

    dpkg -b ./$packdir $debfile
    echo dpkg -b ./$packdir $debfile
    CUPSFILE=$debfile
    rm -fR $wkdir/$packdir   2> /dev/null
  fi

  if [ "$PDRVFILE" != '' ];then
    debfile=$(echo $PDRVFILE | sed s/\.i386.deb/a\.i386.deb/g)
  
    cp $basedir/$PDRVFILE $wkdir/$packdir
    cd $wkdir/$packdir

    dpkg-deb -e $PDRVFILE  DEBIAN
    dpkg -x $PDRVFILE  ./

    cat DEBIAN/control \
	   | sed s/Depends.*$//g \
           | tr -s '\n' \
	   > DEBIAN/control.tmp

    mv -f DEBIAN/control.tmp DEBIAN/control

    rm -f $PDRVFILE   2> /dev/null
    rm -fR usr/share/doc/*   2> /dev/null
    cd $wkdir

    dpkg -b ./$packdir $debfile
    echo dpkg -b ./$packdir $debfile
    PDRVFILE=$debfile
    rm -fR $wkdir/$packdir   2> /dev/null
  fi


  if [ "$CUPSFILE" != '' ];then
    mv $wkdir/$CUPSFILE   $basedir
  fi
  if [ "$LPRFILE" != '' ];then
    mv $wkdir/$LPRFILE    $basedir
  fi
  if [ "$PDRVFILE" != '' ];then
    mv $wkdir/$PDRVFILE   $basedir
  fi
fi

cd $basedir

if [ "$DEBUG_NOINSTALL" != 'yes' ];then
  if [ "$LPRFILE" != '' ];then
    echo -n -e $COLOR4
    echo $PKGCMD  $LPRFILE
    echo -n -e $MONO
    $PKGCMD  $LPRFILE
  fi

  if [ "$CUPSFILE" != '' ];then
    echo -n -e $COLOR4
    echo $PKGCMD  $CUPSFILE 
    echo -n -e $MONO
    $PKGCMD  $CUPSFILE  |  tee ${wkdir}/brother_linux_brprinter_installer.tmp
    echo -n -e $MONO
  fi

  if [ "$PDRVFILE" != '' ];then
    echo -n -e $COLOR4
    echo $PKGCMD  $PDRVFILE 
    echo -n -e $MONO
    $PKGCMD  $PDRVFILE  |  tee "${wkdir}"/brother_linux_brprinter_installer.tmp
    echo -n -e $MONO
  fi
else
  echo -n -e $COLOR4
  if [ "$LPRFILE" != '' ];then
    echo $PKGCMD  $LPRFILE
  fi
  sleep 1
  if [ "$CUPSFILE" != '' ];then
    echo $PKGCMD  $CUPSFILE 
  fi
  sleep 1
  if [ "$PDRVFILE" != '' ];then
    echo $PKGCMD  $PDRVFILE 
  fi

  echo -n -e $MONO
fi
install_done=yes

#if [ "$PKG" = deb ];then
#  rm  -f $LPRFILE   2> /dev/null
#  rm  -f $CUPSFILE   2> /dev/null
#fi


if [ -f "${wkdir}"/brother_linux_brprinter_installer.tmp ];then
  csherr=$(cat ${wkdir}/brother_linux_brprinter_installer.tmp | \
        grep 'ERROR: csh is required') 

  rm "${wkdir}"/brother_linux_brprinter_installer.tmp
  if [ "$csherr" != "" ];then
    echo -e -n $COLOR
    echo $MESSAGE250
    echo -e $MONO
    #DBG_MSG  "exit 19"
    rmdir "${wkdir}"
    exit 0
  fi
fi


#wait for installation end
RAWINSTALLED=yes
if [ "$PRINTERNAME" != UNKNOWN ];then
  retry='0'
  if [ "$DEBUG_NOINSTALL" != 'yes' ];then
    while [ ! -f /etc/cups/ppd/"$PRINTERNAME".ppd ] && [ "$retry" -le $TIMEOUT ] ;do
     sleep 1
     retry=$(($retry+1))
     echo  -n \# 
    done
    if [ -f /etc/cups/ppd/"$PRINTERNAME".ppd ];then
       RAWINSTALLED=no
    fi
  else
    sleep 1
  fi
else
  retry='0'
  if [ "$DEBUG_NOINSTALL" != 'yes' ];then
    while [ $retry -le $TIMEOUT ] ;do
      sleep 1 
      for ppd in $(ls /etc/cups/ppd/*.ppd)
      do
        modelname=$(echo $ppd | sed s/\.ppd//g | sed s/"\/etc\/cups\/"//g)
        modelname2=$(echo $modelname | tr -d '-' | tr "[A-Z]" "[a-z]")
        
        file=$(echo $CUPSFILE | tr -d '-' | tr "[A-Z]" "[a-z]")
        if [ "$(echo $file | grep $modelname2)" != '' ];then
           retry=512
           PRINTERNAME=$(echo $modelname |  tr "[a-z]" "[A-Z]")
           RAWINSTALLED=no
           echo PRINTERNAME=$modelname
           break
        fi
      done 
      retry=$(($retry+1))
      echo -n \#
    done

    if [ "$PRINTERNAME" = UNKNOWN ];then
      
      PRINTERNAME=$(echo $CUPSFILE         | \
	sed s/"^br"//g      		   | \
	sed s/"^cupswrapper"//g		   | \
	sed s/"cupswrapper-.*$"//g	   | \
	sed s/"cupswrapperinch-.*$"//g	   | \
	sed s/"cups-.*$"//g	           | \
	sed s/"-.*$"//g			   | \
	sed s/"_.*$"//g			   | \
	tr "[a-z]" "[A-Z]")
    fi

  else
    sleep 1
  fi
fi

PPDOPT=''
if [ "$RAWINSTALLED" = 'yes' ];then
  for ppd in $(ls /usr/share/ppd/*.ppd /usr/share/cups/model/*.ppd)
  do
    ppd2=$(echo $ppd | tr -d '-')
    prnname=$(echo $PRINTERNAME | tr -d '-')
    if [ "$(echo $ppd2 |  grep -i $prnname)" != '' ];then
       PPDOPT="-P  $ppd"
       break
    fi
  done
fi


echo \#

#------------

if [ "$DUMMYCUPS" = 1 ];then
  if [ "$(ls -al /etc/init.d/cups 2> /dev/null | grep ^l )" != '' ];then
    rm -f /etc/init.d/cups   2> /dev/null
  fi
fi

if [ "$DUMMYCUPSYS" = 1 ];then
  if [ "$(ls -al /etc/init.d/cupsys  2> /dev/null | grep ^l )" != '' ];then
    rm -f /etc/init.d/cupsys   2> /dev/null
  fi
fi

if [ "$DUMMYLPD" = 1 ];then
  if [ "$(ls -al /etc/init.d/lpd  2> /dev/null | grep ^l )" != '' ];then
    rm -f /etc/init.d/lpd   2> /dev/null
  fi
fi

if [ "$DUMMYLPRNG" = 1 ];then
  if [ "$(ls -al /etc/init.d/lprng  2> /dev/null | grep ^l )" != '' ];then
    rm -f /etc/init.d/lprng   2> /dev/null
  fi
fi

#------------



# for SuSE 64
if [ "$arch" != "i386" ];then
  if [ -d "$LIB64FLT" ] && [ -d "$LIBFLT" ] ;then
    filter=$(ls $LIBFLT   2> /dev/null | grep -i $PRINTERNAME | head -n 1  )
    filter64=$(ls $LIB64FLT  2> /dev/null | grep -i $PRINTERNAME | head -n 1 )
    if [ "$filter" != '' ] && [ "$filter64" = '' ];then
      echo cp "$LIBFLT"/$filter   "$LIB64FLT"
      cp "$LIBFLT"/$filter   "$LIB64FLT"
      echo -n -e $COLOR4
      echo $LPADMIN -p $PRINTERNAME -E  $PPDOPT
      echo -n -e $MONO
      $LPADMIN -p $PRINTERNAME -E  $PPDOPT
      rm64filter="rm -f $LIB64FLT/$filter"
    fi
  fi

  if [ -d "$LIB32FLT" ]&& [ -d "$LIBFLT" ] ;then
    filter=$(ls $LIBFLT  2> /dev/null  | grep -i $PRINTERNAME | head -n 1 )
    filter32=$(ls $LIB32FLT  2> /dev/null| grep -i $PRINTERNAME | head -n 1 )
    if [ "$filter" != '' ] && [ "$filter64" = '' ];then
      echo cp "$LIBFLT"/$filter   "$LIB32FLT"
      cp "$LIBFLT"/$filter   "$LIB32FLT"
      echo -n -e $COLOR4
      echo $LPADMIN -p $PRINTERNAME -E  $PPDOPT
      echo -n -e $MONO
      $LPADMIN -p $PRINTERNAME -E  $PPDOPT
      rm32filter="rm -f $LIB64FLT/$filter"
    fi
  fi

fi


## /usr/lib32
LPRPKGNAME=$(echo $LPRFILE       |\
             sed s/"_.*$"//g     |\
             sed s/"-.*$"//g)

pkgpostfix=''

if [ "$PKG" = deb ];then
 if [ "${LPRPKGNAME}" != '' ];then
  if [ "$(dpkg -l | grep ${LPRPKGNAME}:i386)" != '' ];then 
       pkgpostfix=':i386'
  fi
  files=$(dpkg -L "$LPRPKGNAME""$pkgpostfix" | grep '/usr/lib/')
 else
  files=""
 fi
fi


if [ "$PKG" = rpm ];then
 if [ "${LPRPKGNAME}" != '' ];then
  files=$(rpm -q --filesbypkg $LPRPKGNAME | \
	grep '/usr/lib/' | \
	sed s/"$LPRPKGNAME"//g | \
	sed s/' '//g)
 else
  files=""
 fi
fi



#--------------------------------
#    make uninstall script

DBG_MSG "make uninstaller script for printer : uninstaller_${PRINTERNAME}"

uninstaller_prn=uninstaller_${PRINTERNAME}
rm   -f $uninstaller_prn    2> /dev/null
echo "#!  /bin/bash"                              > $uninstaller_prn
echo "#RM_SELINUX_RULE=enable"                    >>$uninstaller_prn


echo "#"                                          >>$uninstaller_prn
echo "#  PRNL=$LPRFILE"                           >>$uninstaller_prn
echo "#  PRNC=$CUPSFILE"                          >>$uninstaller_prn
echo "#  PRNP=$PDRVFILE"                          >>$uninstaller_prn
echo "#  SCAN=$SCANFILE"                          >>$uninstaller_prn
echo "#  SKEY=$SKEYFILE"                          >>$uninstaller_prn
echo "#"                                          >>$uninstaller_prn

for pathlib in $files
do
  pathlib32lib=$(echo $pathlib | \
                 sed s/'\/usr\/lib\/'/'\/usr\/lib32\/'/g)

  if [ -d '/usr/lib32' ];then
     if [ ! -f "$pathlib32lib" ]; then
         if [ "$pathlib" != '' ] && [ "$pathlib32lib" != '' ];then
           echo ln -s $pathlib  $pathlib32lib
	   ln -s $pathlib  $pathlib32lib
	   echo  "rm  -f $pathlib32lib"                  >> $uninstaller_prn
         fi
     fi
  fi
done


## /usr/lib32 symlink


if [ "$files" != '' ];then
  for pathlib in $(ls $(echo "$files"|sed -e s/.so.*$/\*/g))
  do
    if [ -d '/usr/lib32' ];then
      #echo pathlib32lib=$(echo $pathlib | sed -e s/"usr\/lib"/"usr\/lib32"/)
      pathlib32lib=$(echo $pathlib | sed -e s/"usr\/lib"/"usr\/lib32"/)
      if [ ! -f "$pathlib32lib" ]; then
        if [ "$pathlib" != '' ] && [ "$pathlib32lib" != '' ];then
	  echo ln -s $pathlib $pathlib32lib  
	  ln -s $pathlib  $pathlib32lib
	  echo  "rm  -f $pathlib32lib"                   >> $uninstaller_prn
        fi
      fi
    fi
  done
fi

## /lib/lib32 symlink

# AppArmor

if [ "$(which aa-complain  2> /dev/null)" != '' ];then
    echo -e $COLOR$MESSAGE184$MONO          #"AppArmor"
    echo  aa-complain cupsd
    aa-complain cupsd
fi


#  for SELinux

if [ "$(which semanage 2> /dev/null)" = '' ];then
      if   [ "$(which yum 2>/dev/null)" != '' ];then
        echo yum install  policycoreutils-python
        yum install  policycoreutils-python
        echo yum install  policycoreutils
        yum install  policycoreutils
      elif   [ "$(which dnf 2>/dev/null)" != '' ];then
        echo dnf install  policycoreutils-python
        dnf install  policycoreutils-python
        echo dnf install  policycoreutils
        dnf install  policycoreutils
      fi
fi

if [ "$(which semanage 2> /dev/null)" = '' ];then
      if   [ "$(which yum 2>/dev/null)" != '' ];then
        echo yum install  policycoreutils-python-utils
        yum install  policycoreutils-python-utils
      elif   [ "$(which dnf 2>/dev/null)" != '' ];then
        echo dnf install  policycoreutils-python-utils
        dnf install  policycoreutils-python-utils
      fi
fi


if [ "$(which semanage 2> /dev/null)" != '' ];then
 
 echo \if [ \"\$RM_SELINUX_RULE\" = \"enable\" ]\;then   >> $uninstaller_prn
 while read rule 
 do 
  if [ "$rule" != '' ];then
   sedir=$(echo $rule | \
           sed s/"^.*'\/"/"\/"/g | \
           sed s/"\/(.*$"//g     |\
           sed s/"(.*$"//g       |\
           sed s/"'"//g)
   rule2=$(echo $rule | sed s/"'"/""/g)
   rule3=$(echo $rule | sed s/"("/"\("/g | sed s/")"/"\)"/g)
   if [ -d $sedir ]; then
     echo semanage fcontext -a -t $rule2
     semanage fcontext -a -t $rule2
     echo "  "echo semanage fcontext -d -t $rule3 >> $uninstaller_prn
     echo "  "semanage fcontext -d -t $rule3      >> $uninstaller_prn
     echo restorecon -R $sedir
     restorecon -R $sedir
     echo "  "echo restorecon -R $sedir             >> $uninstaller_prn
     echo "  "restorecon -R $sedir                  >> $uninstaller_prn
   fi
  fi
 done  << %%selinux_rules%%

cupsd_rw_etc_t '/usr/local/Brother/Printer/(.*/)?inf(/.*)?'
bin_t          '/usr/local/Brother/Printer/(.*/)?inf/brprintconf(.*)?'
bin_t          '/usr/local/Brother/Printer/(.*/)?lpd(/.*)?'
bin_t          '/usr/local/Brother/Printer/(.*/)?cupswrapper(/.*)?'

bin_t          '/usr/local/Brother'
cupsd_rw_etc_t '/usr/local/Brother/inf(/.*)?'
bin_t          '/usr/local/Brother/lpd(/.*)?'
bin_t          '/usr/local/Brother/cupswrapper(/.*)?'

bin_t          '/opt/brother'
cupsd_rw_etc_t '/etc/opt/brother'
cupsd_rw_etc_t '/opt/brother/Printers/(.*/)?inf(/.*)?'
cupsd_rw_etc_t '/etc/opt/brother/Printers/(.*/)?inf(/.*)?'
bin_t          '/opt/brother/Printers/(.*/)?lpd(/.*)?'
bin_t          '/opt/brother/Printers/(.*/)?cupswrapper(/.*)?'


%%selinux_rules%%

  if [ -e $LIBFLT ] ;then
    echo restorecon -RFv $LIBFLT
    restorecon -RFv $LIBFLT
  fi
  if [ -e $LIB32FLT ] ;then
    echo restorecon -RFv $LIB32FLT
    restorecon -RFv $LIB32FLT
  fi
  if [ -e $LIB64FLT ] ;then
    echo restorecon -RFv $LIB64FLT
    restorecon -RFv $LIB64FLT
  fi
  echo  setsebool -P cups_execmem 1
  setsebool -P cups_execmem 1
  echo  "  echo setsebool -P cups_execmem 0"  >> $uninstaller_prn
  echo  "  setsebool -P cups_execmem 0"       >> $uninstaller_prn

 echo fi    >> $uninstaller_prn

fi




## Configure Device URI

if [ "$RAWINSTALLED" = no ];then
  echo -e -n $COLOR$MESSAGE190 #"Will you specify the Device URI\? [y/N] ->"
  read answer
  echo -e $MONO
else
  answer=Y
fi

if [ "$answer" != n ] && [ "$answer" != N ]; then
  duri=$($LPINFO -v  | sed s/'^.* '//g  | \
                       grep -v 'brserial_' | grep -v 'brusb_')
  i=0
  echo -e $COLOR4

  autodurin=""
  for deviceuri in $duri
  do
    prnn2=$(echo $PRINTERNAME | tr -d '-' | tr "[A-Z]" "[a-z]")
    duri2=$(echo $deviceuri   | tr -d '-' | tr "[A-Z]" "[a-z]")
    if [ "$(echo $duri2 | grep 'usb://brother' |grep $prnn2 2>/dev/null )" \
               != '' ];then
      autodurin=$i
      autoduris=$deviceuri
      break
    else
      i=$(($i+1))
    fi
  done

  if [ "$autodurin" = '' ];then
    i=0
    for deviceuri in $duri
    do
      prnn2=$(echo $PRINTERNAME | tr -d '-' | tr "[A-Z]" "[a-z]")
      duri2=$(echo $deviceuri   | tr -d '-' | tr "[A-Z]" "[a-z]")
      if [ "$(echo $duri2  | grep  $prnn2 2>/dev/null)" != '' ];then
        autodurin=$i
        autoduris=$deviceuri
        break
      else
        i=$(($i+1))
      fi
    done
  fi

  if [ "$autodurin" = '' ];then
    i=0
    for deviceuri in $duri
    do
      prnn2=$(echo $PRINTERNAME | tr -d '-' | tr "[A-Z]" "[a-z]")
      duri2=$(echo $deviceuri   | tr -d '-' | tr "[A-Z]" "[a-z]")
      if [ "$(echo $duri2  | grep  'usb://brother' 2>/dev/null)" != '' ];then
        autodurin=$i
        autoduris=$deviceuri
      else
        i=$(($i+1))
      fi
    done
  fi

  if [ "$autoduris" = '' ];then
    autoduris='usb://dev/usblp0'
  fi 

  i=0
  for deviceuri in $duri
  do
    echo $i: $deviceuri
    i=$(($i+1))
  done
  echo -e  $i "(I)": $MESSAGE200   #"Specify IP address."
  i=$(($i+1))
  echo -e  $i "(A)": $MESSAGE201 "("$autoduris")"  #"Auto."
  echo -e $MONO

  echo -e -n  $COLOR$MESSAGE210       #"select the number of distination Device URI. ->"
  read answer
  echo -e $MONO

  if [ "$answer" = "$((i-1))" ] || \
     [ "$answer" = 'IP' ] || \
     [ "$answer" = 'ip' ] || \
     [ "$answer" = 'Ip' ] || \
     [ "$answer" = 'i' ] || \
     [ "$answer" = 'I' ];then
    echo -e -n $COLOR$MESSAGE220          #"  enter IP address ->"
    read ipadrs
    echo -n -e $COLOR4
    echo $LPADMIN -p $PRINTERNAME -v socket://$ipadrs -E   $PPDOPT
    echo -e -n $MONO
    $LPADMIN -p $PRINTERNAME -v socket://$ipadrs -E    $PPDOPT
    deviceuri=socket://$ipadrs
  elif [ "$answer" = "$i" ] || \
       [ "$answer" = 'A' ]        || \
       [ "$answer" = 'a' ]        || \
       [ "$answer" = 'Auto' ]     || \
       [ "$answer" = '' ] ;then
    echo -n -e $COLOR4
    echo $LPADMIN -p $PRINTERNAME -v $autoduris -E   $PPDOPT
    echo -n -e $MONO
    $LPADMIN -p $PRINTERNAME -v $autoduris -E   $PPDOPT
    deviceuri=$autoduris
  elif [ "$answer" = 'F' ] || [ "$answer" = 'f' ];then
    echo -n -e $COLOR4
    echo $LPADMIN -p $PRINTERNAME -v file:///tmp/printdata.prn -E    $PPDOPT
    echo -n -e $MONO
    $LPADMIN -p $PRINTERNAME -v file:///tmp/printdata.prn -E    $PPDOPT
    deviceuri="file:///tmp/printdata.prn"
  else
   i=0
   for deviceuri in $duri
   do
     if [ "$i" = "$answer" ];then
       echo -e -n $COLOR4
       echo $LPADMIN -p $PRINTERNAME -v $deviceuri -E    $PPDOPT
       echo -e -n $MONO
       $LPADMIN -p $PRINTERNAME -v $deviceuri -E    $PPDOPT
       break
     fi
     i=$(($i+1))
   done
  fi
elif [ "$answer" = "file" ] || [ "$answer" = "File" ]; then
    echo -e -n $COLOR4
    echo $LPADMIN -p $PRINTERNAME -v file:///tmp/printdata.prn -E    $PPDOPT
    echo -e -n $MONO
    $LPADMIN -p $PRINTERNAME -v file:///tmp/printdata.prn -E    $PPDOPT
fi

if [ "${modelnhuc}" = 'FAX' ];then
  if [ -e /usr/lib/cups/filter/brfaxfilter ];then
    chmod 755 /usr/lib/cups/filter/brfaxfilter
  fi

  if [ -e /usr/lib32/cups/filter ];then
    if [ ! -e /usr/lib32/cups/filter/brfaxfilter ];then
      cp /usr/lib/cups/filter/brfaxfilter /usr/lib32/cups/filter/brfaxfilter
    fi
    chmod 755 /usr/lib32/cups/filter/brfaxfilter
  fi
  if [ -e /usr/lib64/cups/filter ];then
    if [ ! -e /usr/lib64/cups/filter/brfaxfilter ];then
      cp /usr/lib/cups/filter/brfaxfilter /usr/lib64/cups/filter/brfaxfilter
    fi
    chmod 755 /usr/lib64/cups/filter/brfaxfilter
  fi

  if [ -f /etc/init.d/cups ];then
     /etc/init.d/cups restart
  elif [ -f /etc/init.d/cupsys ];then
     /etc/init.d/cupsys restart
  else 
     service cups restart
  fi

fi




socketdevice=$(echo "$deviceuri" | grep "socket:")

if [ -n "$socketdevice" ] && [ "$ipadrs" = '' ];then
    ipadrs=$(echo $socketdevice | sed s/"socket:\/\/"//g  | sed s/":.*$"//g)
fi

echo -e -n $COLOR$MESSAGE230         #"Test Print \? [y/N]. ->"
read answer
echo -e $MONO

if [ "$answer" = Y ] || [ "$answer" = y ]; then
  echo  wait 5s.
  sleep 5

  if [ -f $TESTPRINT ];then
    echo lpr  -P $PRINTERNAME $TESTPRINT
    lpr  -P "$PRINTERNAME" "$TESTPRINT"
  elif [ -f $TESTPRINT2 ];then
    echo lpr  -P $PRINTERNAME $TESTPRINT2
    lpr  -P "$PRINTERNAME" "$TESTPRINT2"
  else
    echo "echo $PRINTERNAME \| lpr  -P $PRINTERNAME"
    echo "$PRINTERNAME" | lpr  -P "$PRINTERNAME"
  fi
fi

# Make uninstaller   : daemon symlink

LPRPKGNAME=$(echo $LPRFILE       |\
             sed s/"_.*$"//g     |\
             sed s/"-.*$"//g)
CUPSPKGNAME=$(echo $CUPSFILE    |\
             sed s/"_.*$"//g     |\
             sed s/"-.*$"//g)
PDRVPKGNAME=$(echo $PDRVFILE    |\
             sed s/"_.*$"//g     |\
             sed s/"-.*$"//g)






echo "if ! [ -f /etc/init.d/cupsys ];then"           >>$uninstaller_prn
echo " DUMMYCUPSYS=1"                                >>$uninstaller_prn
echo " ln -s /bin/true  /etc/init.d/cupsys"          >>$uninstaller_prn
echo "fi"                                            >>$uninstaller_prn

echo "if ! [ -f /etc/init.d/cups ];then"             >>$uninstaller_prn
echo " DUMMYCUPS=1"                                  >>$uninstaller_prn
echo " ln -s /bin/true  /etc/init.d/cups"            >>$uninstaller_prn
echo "fi"                                            >>$uninstaller_prn

echo "if ! [ -f /etc/init.d/lpd ];then"              >>$uninstaller_prn
echo " DUMMYLPD=1"                                   >>$uninstaller_prn
echo " ln -s /bin/true  /etc/init.d/lpd"             >>$uninstaller_prn
echo "fi"                                            >>$uninstaller_prn

echo "if ! [ -f /etc/init.d/lprng ];then"            >>$uninstaller_prn
echo " DUMMYLPRNG=1"                                 >>$uninstaller_prn
echo " ln -s /bin/true  /etc/init.d/lprng"           >>$uninstaller_prn
echo "fi"                                            >>$uninstaller_prn




#
#rm cupswrapper driver
if [ "$CUPSPKGNAME" != '' ];then
  echo "$PREPKGCMDC"                                   >>$uninstaller_prn
  echo "$RMPKGCMD    $CUPSPKGNAME""$pkgpostfix"        >>$uninstaller_prn
fi
#
#rm lpd driver
if [ "$LPRPKGNAME" != '' ];then
  echo "$PREPKGCMDL"                                   >>$uninstaller_prn
  echo "$RMPKGCMD    $LPRPKGNAME""$pkgpostfix"         >>$uninstaller_prn
fi

#rm pdrv driver
if [ "$PDRVPKGNAME" != '' ];then
  echo "$PREPKGCMDP"                                   >>$uninstaller_prn
  echo "$RMPKGCMD    $PDRVPKGNAME""$pkgpostfix"         >>$uninstaller_prn
fi



if [ "$DUMMYCUPS" = 1 ]   || \
   [ "$DUMMYCUPSYS" = 1 ] || \
   [ "$DUMMYLPD" = 1 ]    || \
   [ "$DUMMYLPRNG" = 1 ];then


  echo 'if [ "$DUMMYCUPS" = 1 ];then'                  >>$uninstaller_prn
  echo '  lsc=$(ls -al /etc/init.d/cups  2> /dev/null| grep ^l)'   >>$uninstaller_prn
  echo '  if [ "$lsc" != "" ];then'                    >>$uninstaller_prn
  echo '    rm -f /etc/init.d/cups'                    >>$uninstaller_prn
  echo '  fi'                                          >>$uninstaller_prn
  echo 'fi'                                            >>$uninstaller_prn
  echo ''                                              >>$uninstaller_prn

  echo 'if [ "$DUMMYCUPSYS" = 1 ];then'                >>$uninstaller_prn
  echo '  lsc=$(ls -al /etc/init.d/cupsys  2> /dev/null| grep ^l)' >>$uninstaller_prn
  echo '  if [ "$lsc" != "" ];then'                    >>$uninstaller_prn
  echo '    rm -f /etc/init.d/cupsys'                  >>$uninstaller_prn
  echo '  fi'                                          >>$uninstaller_prn
  echo 'fi'                                            >>$uninstaller_prn
  echo ''                                              >>$uninstaller_prn

  echo 'if [ "$DUMMYLPD" = 1 ];then'                   >>$uninstaller_prn
  echo '  lsc=$(ls -al /etc/init.d/lpd  2> /dev/null | grep ^l)'   >>$uninstaller_prn
  echo '  if [ "$lsc" != "" ];then'                    >>$uninstaller_prn
  echo '    rm -f /etc/init.d/lpd'                     >>$uninstaller_prn
  echo '  fi'                                          >>$uninstaller_prn
  echo 'fi'                                            >>$uninstaller_prn
  echo ''                                              >>$uninstaller_prn

  echo 'if [ "$DUMMYLPRNG" = 1 ];then'                 >>$uninstaller_prn
  echo '  lsc=$(ls -al /etc/init.d/lprng | grep ^l)'   >>$uninstaller_prn
  echo '  if [ "$lsc" != "" ];then'                    >>$uninstaller_prn
  echo '    rm -f /etc/init.d/lprng'                   >>$uninstaller_prn
  echo '  fi'                                          >>$uninstaller_prn
  echo 'fi'                                            >>$uninstaller_prn


  echo  $rm32filter                                    >>$uninstaller_prn
  echo  $rm64filter                                    >>$uninstaller_prn

fi 


if [ "$SCAN" != '' ];then
  echo $SCAN
fi

if [ "$SKEY" != '' ];then
  echo $SKEY
fi

chmod 744 $uninstaller_prn

pre_proc
scanner_install          #    scanner
post_proc

if [ "$1" = '' ];then
  echo -e -n $COLOR$MESSAGE240$MONO    #"Hit Return/Enter Key"
  read answer
fi
#DBG_MSG  "exit 20"
rmdir "${wkdir}"
exit 0
