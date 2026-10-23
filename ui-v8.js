/* UI-only sync of reference-style buttons with existing inputs. No data or Supabase calls. */
(()=>{
  const unit=document.getElementById('unit');
  const chips=[...document.querySelectorAll('.v8-unit-chips button')];
  function syncUnit(){chips.forEach(b=>{const current=b.dataset.unit===unit.value;b.classList.toggle('selected',current);b.setAttribute('aria-pressed',String(current));});}
  chips.forEach(b=>b.addEventListener('click',()=>{unit.value=b.dataset.unit;unit.dispatchEvent(new Event('change',{bubbles:true}));syncUnit();}));
  unit.addEventListener('change',syncUnit);
  const bypass=document.getElementById('bypassPacu');
  const pacuBtn=document.getElementById('v8PacuButton');
  const passBtn=document.getElementById('v8PassButton');
  function syncPacu(){pacuBtn.classList.toggle('is-active',!bypass.checked);passBtn.classList.toggle('is-active',bypass.checked);pacuBtn.setAttribute('aria-pressed',String(!bypass.checked));passBtn.setAttribute('aria-pressed',String(bypass.checked));}
  for(const b of [pacuBtn,passBtn])b.addEventListener('click',()=>{bypass.checked=b.dataset.pacu==='true';bypass.dispatchEvent(new Event('change',{bubbles:true}));syncPacu();});
  bypass.addEventListener('change',syncPacu);
  const form=document.getElementById('form');
  new MutationObserver(()=>{if(form.classList.contains('active')){syncUnit();syncPacu();}}).observe(form,{attributes:true,attributeFilter:['class']});
  document.getElementById('patientForm').addEventListener('reset',()=>setTimeout(()=>{syncUnit();syncPacu();},0));
  syncUnit();syncPacu();
})();
