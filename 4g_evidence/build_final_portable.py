import struct,csv,collections,os,json,math
from pathlib import Path
B=Path(__file__).resolve().parent;OUT=B;OUT.mkdir(exist_ok=True)
MASK=0xffffffff

def signed(x,bits=32):
 x&=(1<<bits)-1
 return x-(1<<bits) if x>>(bits-1) else x

def parseelf(path):
 data=Path(path).read_bytes(); assert data[:4]==b'\x7fELF' and data[4]==1
 e=struct.unpack_from('<16sHHIIIIIHHHHHH',data,0)
 entry=e[4]; phoff=e[5]; shoff=e[6]; phentsize=e[9];phnum=e[10];shentsize=e[11];shnum=e[12];shstrndx=e[13]
 mem={}
 for n in range(phnum):
  p=struct.unpack_from('<IIIIIIII',data,phoff+n*phentsize)
  if p[0]==1:
   _,off,vaddr,paddr,filesz,memsz,flags,align=p
   for i in range(filesz):mem[(vaddr+i)&MASK]=data[off+i]
   for i in range(filesz,memsz):mem[(vaddr+i)&MASK]=0
 sections=[]
 for n in range(shnum):
  s=struct.unpack_from('<IIIIIIIIII',data,shoff+n*shentsize)
  sections.append({'nameidx':s[0],'type':s[1],'addr':s[3],'offset':s[4],'size':s[5],'link':s[6],'entsize':s[9]})
 st=sections[shstrndx];tab=data[st['offset']:st['offset']+st['size']]
 for s in sections:s['name']=tab[s['nameidx']:].split(b'\0')[0].decode(errors='replace')
 symbols={}
 for sec in sections:
  if sec['type']==2:
   strsec=sections[sec['link']];stb=data[strsec['offset']:strsec['offset']+strsec['size']]
   for p in range(sec['offset'],sec['offset']+sec['size'],sec['entsize']):
    if p+16>len(data):break
    n,v,z,info,other,shndx=struct.unpack_from('<IIIBBH',data,p)
    name=stb[n:].split(b'\0')[0].decode(errors='replace');
    if name:symbols[name]=(v,z)
 return entry,mem,sections,symbols

def run(path, filename):
 entry,mem,sections,syms=parseelf(path)
 r=[0]*32;r[2]=0x7ffffff0;r[3]=0x10000000
 # clang-linked main at entry, return address 0 means exit
 pc=entry; trace=[];dyn=[]; counter=0; halted='';
 def rd(a):return sum(mem.get((a+j)&MASK,0)<<(8*j) for j in range(4))
 def wr(a,v):
  for j in range(4):mem[(a+j)&MASK]=(v>>(8*j))&255
 while counter<500000:
  if pc==0: halted='main returned';break
  if pc&3:halted='unaligned pc '+hex(pc);break
  w=rd(pc);op=w&127;rdn=(w>>7)&31;f3=(w>>12)&7;rs1=(w>>15)&31;rs2=(w>>20)&31;f7=(w>>25)&127
  a=r[rs1];b=r[rs2];imm_i=signed(w>>20,12)
  npc=(pc+4)&MASK;v=None;mn='';access=[]
  if op==0x37: v=w&0xfffff000;mn='lui'
  elif op==0x17:v=(pc+(w&0xfffff000))&MASK;mn='auipc'
  elif op==0x13:
   if f3==0: v=a+imm_i;mn='addi'
   elif f3==1:v=(a<<((w>>20)&31));mn='slli'
   elif f3==5:
    sh=(w>>20)&31
    if (w>>30)&1:v=signed(a)>>sh;mn='srai'
    else:v=a>>sh;mn='srli'
   elif f3==7:v=a & (imm_i&MASK);mn='andi'
   elif f3==6:v=a | (imm_i&MASK);mn='ori'
   elif f3==4:v=a ^ (imm_i&MASK);mn='xori'
   elif f3==2:v=int(signed(a)<imm_i);mn='slti'
   elif f3==3:v=int(a<(imm_i&MASK));mn='sltiu'
   else:raise RuntimeError(('op13',hex(pc),hex(w)))
  elif op==0x33:
   if f7==1:
    if f3==0:v=a*b;mn='mul'
    elif f3==3:v=(a*b)>>32;mn='mulhu'
    elif f3==2:v=(signed(a)*b)>>32;mn='mulhsu'
    elif f3==1:v=(signed(a)*signed(b))>>32;mn='mulh'
    else:raise RuntimeError(('mul unknown',hex(w)))
   elif f3==0:
    if f7==0x20:v=a-b;mn='sub'
    else:v=a+b;mn='add'
   elif f3==4:v=a^b;mn='xor'
   elif f3==6:v=a|b;mn='or'
   elif f3==7:v=a&b;mn='and'
   elif f3==1:v=a<<(b&31);mn='sll'
   elif f3==5:v=(signed(a)>>(b&31)) if f7==0x20 else a>>(b&31);mn='sra' if f7==0x20 else 'srl'
   elif f3==2:v=int(signed(a)<signed(b));mn='slt'
   elif f3==3:v=int(a<b);mn='sltu'
   else:raise RuntimeError(('op33',hex(pc),hex(w)))
  elif op==3:
   addr=(a+imm_i)&MASK
   if f3==2: v=rd(addr);mn='lw';sz=4
   elif f3==0:v=signed(mem.get(addr,0),8);mn='lb';sz=1
   elif f3==4:v=mem.get(addr,0);mn='lbu';sz=1
   else:raise RuntimeError(('load',hex(w)))
   access.append(('R',addr,sz,v&MASK))
  elif op==0x23:
   imm=signed(((w>>25)<<5)|((w>>7)&31),12);addr=(a+imm)&MASK
   if f3==2:wr(addr,b);mn='sw';sz=4
   elif f3==0:mem[addr]=b&255;mn='sb';sz=1
   else:raise RuntimeError(('store',hex(w)))
   access.append(('W',addr,sz,b&MASK))
  elif op==0x63:
   imm=signed((((w>>31)&1)<<12)|(((w>>7)&1)<<11)|(((w>>25)&63)<<5)|(((w>>8)&15)<<1),13)
   cond={0:a==b,1:a!=b,4:signed(a)<signed(b),5:signed(a)>=signed(b),6:a<b,7:a>=b}[f3]
   mn={0:'beq',1:'bne',4:'blt',5:'bge',6:'bltu',7:'bgeu'}[f3]
   if cond:npc=(pc+imm)&MASK
  elif op==0x6f:
   imm=signed((((w>>31)&1)<<20)|(((w>>12)&255)<<12)|(((w>>20)&1)<<11)|(((w>>21)&1023)<<1),21)
   v=npc;npc=(pc+imm)&MASK;mn='jal'
  elif op==0x67:
   v=npc;npc=(a+imm_i)&(~1)&MASK;mn='jalr'
  elif op==0x73:
   if w==0x00000073:halted='ecall';break
   elif w==0x00100073:halted='ebreak';break
   else:raise RuntimeError(('system',hex(pc),hex(w)))
  else:raise RuntimeError(('unknown',hex(pc),hex(w),r))
  old=r[rdn];
  if v is not None and rdn:r[rdn]=v&MASK
  r[0]=0
  dyn.append({'seq':counter+1,'pc':pc,'word':w,'mn':mn,'rd':rdn if v is not None else None,'result':r[rdn] if (v is not None and rdn) else None,'next_pc':npc,'access':access,'rs1':rs1,'rs2':rs2,'a':a,'b':b})
  for rw,addr,sz,value in access:
   counterindex=len(trace)+1
   isstack=(0x70000000<=addr<=0x80000000)
   isarray=syms.get('data',(0,0))[0]<=addr<syms.get('data',(0,0))[0]+syms.get('data',(0,0))[1]
   trace.append({'sira':counterindex,'RW':rw,'adres_hex':f'0x{addr:08X}','boyut':sz,'c_satiri':'','stack_mi':int(isstack),'pc':f'0x{pc:08X}','deger_hex':f'0x{value:08X}','ana_dizi_mi':int(isarray)})
  pc=npc;counter+=1
 else: halted='instruction cap'
 with open(OUT/filename,'w',newline='') as f:
  cw=csv.DictWriter(f,fieldnames=['sira','RW','adres_hex','boyut','c_satiri','stack_mi','pc','deger_hex','ana_dizi_mi']);cw.writeheader();cw.writerows(trace)
 print(Path(path).name,'entry',hex(entry),'halt',halted,'instructions',counter,'memory',len(trace),'sym', {k:hex(v[0]) for k,v in syms.items() if k in ('data','checksum','decrypt_ok','main')})
 print('final result', [f'{name} = {rd(syms[name][0])}' for name in ('checksum','decrypt_ok','data')])
 return trace,dyn,syms,sections,mem

def cache_sim(trace,size=128,line=16,ways=1,policy='write-back'):
 lines=size//line;sets=lines//ways;cache=[[{'valid':False,'dirty':False,'tag':None,'block':None,'last':0} for _ in range(ways)] for j in range(sets)]
 hits=misses=writes=0;compulsory=set();out=[]
 for i,acc in enumerate(trace,1):
  addr=int(acc['adres_hex'],16);block=addr//line;setid=block%sets;tag=block//sets;entries=cache[setid]
  found=next((x for x in entries if x['valid'] and x['tag']==tag),None)
  hit=found is not None
  if hit:hits+=1;victim=found;evicted=None;was_before=True
  else:
   misses+=1
   victim=next((x for x in entries if not x['valid']),None)
   if victim is None:victim=min(entries,key=lambda x:x['last'])
   evicted=f'0x{victim["block"]*line:08X}' if victim['valid'] else '-'
   if victim['valid'] and victim['dirty']:writes+=1
   victim.update(valid=True,dirty=False,tag=tag,block=block)
   was_before=block in compulsory
  compulsory.add(block)
  victim['last']=i
  if acc['RW']=='W':
   if policy=='write-back':victim['dirty']=True
   else:writes+=1
  out.append({'sira':i,'RW':acc['RW'],'adres_hex':acc['adres_hex'],'tag':f'0x{tag:X}','line_set':setid,'word_offset':addr%line,'hit_miss':'Hit' if hit else 'Miss','evicted':evicted,'block_seen_before':'Yes' if was_before else 'No'})
 state=[]
 for j,entries in enumerate(cache):
  for k,x in enumerate(entries):state.append({'line':j*ways+k,'set':j,'valid':int(x['valid']),'tag':f'0x{x["tag"]:X}' if x['valid'] else '-', 'dirty':int(x['dirty']),'block':f'0x{x["block"]*line:08X}' if x['valid'] else '-','lru_rank':sorted([y['last'] for y in entries]).index(x['last'])+1 if x['valid'] and ways>1 else '-'})
 return {'references':len(trace),'hits':hits,'misses':misses,'hit_ratio':hits/len(trace),'memory_writes':writes,'dirty_remaining':sum(x['dirty'] for y in cache for x in y),'details':out,'state':state}

if __name__=='__main__':
 import json, csv
 for opt in ('O0','O1'):
  trace,dyn,s,sects,mem=run(B/f'g3_{opt}.elf',f'live_trace_{opt}.csv')
  c=cache_sim(trace)
  print(opt, len(dyn), 'data refs',len(trace),'hit',c['hits'],'miss',c['misses'],'H',f'{c["hit_ratio"]:.6f}')
  if opt=='O0':
   with (B/'live_cache_first30.csv').open('w',newline='') as f:
    w=csv.DictWriter(f,fieldnames=list(c['details'][0]));w.writeheader();w.writerows(c['details'][:30])
